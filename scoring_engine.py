import joblib
import json
import numpy as np
import os

# Get the directory of the current script
current_dir = os.path.dirname(os.path.abspath(__file__))

# --- Load Feature Order (Ensures generic feature mapping) ---
try:
    with open(os.path.join(current_dir, 'feature_order.txt'), 'r') as f:
        FEATURE_ORDER = [line.strip() for line in f.readlines() if line.strip()]
    print("✅ Feature Order loaded successfully")
except Exception as e:
    FEATURE_ORDER = []
    print(f"❌ Failed to load feature order: {e}")

def get_rating_level(prob):
    """
    Standard PD-to-Rating Mapping 
    (Reflecting Bank Internal Rating Based approach)
    """
    if prob < 0.01: return 'AAA'
    elif prob < 0.03: return 'AA'
    elif prob < 0.07: return 'A'
    elif prob < 0.15: return 'BBB'
    elif prob < 0.30: return 'BB'
    elif prob < 0.50: return 'B'
    elif prob < 0.80: return 'C'   # High Risk / Watchlist
    else: return 'D'             # Default imminent

# --- Version-paired Inference Logic ---
def run_ml_prediction(json_data, model_path):
    try:
        # 1. Determine absolute model path
        full_model_path = model_path
        if not os.path.exists(full_model_path):
            return None, f"Model file not found: {model_path}"
        
        # 2. Automatically match version-paired Scaler
        models_folder = os.path.dirname(full_model_path)
        model_filename = os.path.basename(full_model_path)
        
        if "credit_risk_model.pkl" in model_filename:
            scaler_filename = "scaler.pkl"
        else:
            scaler_filename = model_filename.replace("model_", "scaler_")
        
        full_scaler_path = os.path.join(models_folder, scaler_filename)
        
        if not os.path.exists(full_scaler_path):
            full_scaler_path = os.path.join(models_folder, 'scaler.pkl')

        # 3. Load artifacts
        current_model = joblib.load(full_model_path)
        current_scaler = joblib.load(full_scaler_path)
        
        # Debug: Display the current paired-artifacts in console
        print(f"🔍 Inference using: {model_filename} & {os.path.basename(full_scaler_path)}")

        # 4. Parse JSON and align with Feature Order
        data_dict = json.loads(json_data)
        input_vector = []
        for feat in FEATURE_ORDER:
            # Handle missing values: default to 0.0 if feature is missing from JSON
            val = data_dict.get(feat, 0.0)
            input_vector.append(float(val))
        
        # 5. Matrix transformation and Standardization
        final_input = np.array(input_vector).reshape(1, -1)
        final_input_scaled = current_scaler.transform(final_input)
        
        # 6. Execute Probability Calculation
        prob_default = current_model.predict_proba(final_input_scaled)[0][1]
        rating_level = get_rating_level(prob_default)
        
        return prob_default, rating_level
        
    except Exception as e:
        return None, f"Prediction Error: {str(e)}"