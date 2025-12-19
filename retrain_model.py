import pandas as pd
import joblib
import argparse
import datetime
import os
from dotenv import load_dotenv
import sys
from io import StringIO
from azure.storage.blob import BlobServiceClient
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from imblearn.over_sampling import SMOTE
from sklearn.ensemble import RandomForestClassifier

load_dotenv()

# CLI arguments for automation
parser = argparse.ArgumentParser()
parser.add_argument("--data", type=str, required=True, help="Filename of the CSV snapshot in Azure")
args = parser.parse_args()

# --- 1. Versioning: Generate timestamped filenames ---
ts = datetime.datetime.now().strftime("%Y%m%d_%H%M")
new_model_name = f"model_{ts}.pkl"
new_scaler_name = f"scaler_{ts}.pkl"
current_dir = os.path.dirname(os.path.abspath(__file__))

models_dir = os.path.join(current_dir, 'models')
os.makedirs(models_dir, exist_ok=True)

# --- 2. Data Ingestion from Azure Blob Storage ---
conn_str = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
service = BlobServiceClient.from_connection_string(conn_str)
blob_client = service.get_blob_client(container="raw-data", blob=args.data)
df = pd.read_csv(StringIO(blob_client.download_blob().readall().decode("utf-8")))

# --- 3. Data Preprocessing & Safety Split ---
# Assuming first column is the target label (0: Normal, 1: Bankrupt)
X = df.drop(df.columns[0], axis=1)
y = df[df.columns[0]]

# Safety Check: Use stratified split only if there are enough samples per class
if y.value_counts().min() < 2:
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
else:
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

# --- 4. Model Fitting Pipeline ---
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

# Handle Class Imbalance using SMOTE
smote = SMOTE(random_state=42)
X_res, y_res = smote.fit_resample(X_train_scaled, y_train)

# Initialize and train the Random Forest Classifier
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_res, y_res)

# --- 5. Persistence (Artifact Registry) ---
# Save the versioned artifacts
joblib.dump(model, os.path.join(models_dir, new_model_name))
joblib.dump(scaler, os.path.join(models_dir, new_scaler_name))

# Also update default pointers for system initialization
joblib.dump(model, os.path.join(models_dir, 'credit_risk_model.pkl'))
joblib.dump(scaler, os.path.join(models_dir, 'scaler.pkl'))

# Print SUCCESS tag for app.py to capture and display
print(f"SUCCESS:{new_model_name}")