import streamlit as st
import mysql.connector
import pandas as pd
from scoring_engine import run_ml_prediction
import warnings
import json
from azure.storage.blob import BlobServiceClient
from io import StringIO
import re
import os
from dotenv import load_dotenv
import sys
import subprocess
import urllib.parse
import datetime

# --- [1. Configuration & Global State] ---
# Professional Title: Reflects the universal nature of the engine
st.set_page_config(page_title="AI Risk Lab", layout="wide")
BASE_PATH = os.path.dirname(os.path.abspath(__file__))
MODELS_PATH = os.path.join(BASE_PATH, "models")
if not os.path.exists(MODELS_PATH):
    os.makedirs(MODELS_PATH)

load_dotenv()

# Azure Storage Credentials
AZURE_STR = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
CONTAINER = "raw-data"
BLOB_NAME_LATEST = "bankruptcy_data_latest.csv"

# MySQL Database Credentials
db_password = os.getenv("MYSQL_PASSWORD")

def get_db_conn():
    """Establishes connection to the Azure MySQL database."""
    return mysql.connector.connect(
        host="dms-project-25.mysql.database.azure.com",
        user="fei", password=db_password, database="mydb", port=3306
    )

# --- [2. Data Management Logic] ---
def sync_to_azure(c_id, is_bankrupt, base_blob):
    """Syncs new labels to Azure and creates a versioned data snapshot."""
    try:
        conn = get_db_conn()
        cursor = conn.cursor(dictionary=True)
        # Fetch financial JSON using Customer_id (Party_id)
        cursor.execute("SELECT Full_report_json FROM financial_data WHERE Customer_id = %s", (c_id,))
        row = cursor.fetchone()
        if not row: return False, "Customer ID not found in financial records."
        
        service = BlobServiceClient.from_connection_string(AZURE_STR)
        blob_client_base = service.get_blob_client(CONTAINER, base_blob)
        existing_data = pd.read_csv(StringIO(blob_client_base.download_blob().readall().decode("utf-8")))
        
        # Parse and align features (Numeric sorting by JSON keys for model consistency)
        data_dict = json.loads(row['Full_report_json'])
        ordered_vals = [float(data_dict[k]) for k in sorted(data_dict.keys(), key=lambda x: int(re.findall(r'\d+', x)[0]) if re.findall(r'\d+', x) else 0)]
        new_row = pd.DataFrame([[int(is_bankrupt)] + ordered_vals], columns=existing_data.columns.tolist())
        updated_df = pd.concat([existing_data, new_row], ignore_index=True)
        
        # Save both Latest pointer and a Timestamped Snapshot for audit/lineage
        ts = datetime.datetime.now().strftime("%Y%m%d_%H%M")
        snapshot_name = f"snapshot_{ts}.csv"
        csv_bin = updated_df.to_csv(index=False)
        service.get_blob_client(CONTAINER, BLOB_NAME_LATEST).upload_blob(csv_bin, overwrite=True)
        service.get_blob_client(CONTAINER, snapshot_name).upload_blob(csv_bin, overwrite=True)
        
        conn.close()
        return True, snapshot_name
    except Exception as e: return False, str(e)

# --- [3. Global Pre-loading] ---
try:
    service = BlobServiceClient.from_connection_string(AZURE_STR)
    container_client = service.get_container_client(CONTAINER)
    # Load all versioned snapshots from Azure Cloud
    csv_versions = sorted([b.name for b in container_client.list_blobs() if b.name.endswith('.csv')], reverse=True)
except:
    csv_versions = [BLOB_NAME_LATEST]

# --- [4. Sidebar: Governance Context] ---
with st.sidebar:
    st.title("🛡️ AI Risk Lab")
    st.caption("Advanced Risk Assessment Environment")
    st.markdown("---")
    st.subheader("📦 Inference Context")
    
    # Registry: Scan for locally stored pkl models
    all_models = sorted([f for f in os.listdir(MODELS_PATH) if f.endswith('.pkl') and f.startswith('model_')], reverse=True)
    if os.path.exists(os.path.join(MODELS_PATH, 'credit_risk_model.pkl')):
        all_models.append('credit_risk_model.pkl')
    
    if not all_models:
        all_models = ["No models found"]

    # Maintain chosen model version in session state to prevent auto-switching after reruns
    if 'current_model_choice' not in st.session_state:
        st.session_state.current_model_choice = all_models[0]

    try:
        current_index = all_models.index(st.session_state.current_model_choice)
    except ValueError:
        current_index = 0

    st.session_state.current_model_choice = st.selectbox(
        "▶ Active Model Version", 
        all_models, 
        index=current_index,
        help="Manually activate models. New training runs won't deploy until selected here."
    )
    
    selected_model = st.session_state.current_model_choice
    st.success(f"● Model Active: `{selected_model}`")
    st.info(f"● Baseline: `{csv_versions[0] if csv_versions else 'N/A'}`")

# --- [5. Section 1: Business Assessment Workflow] ---
st.header("⚡ AI Real-time Risk Scoring Workspace")
conn = get_db_conn()
df_todo = pd.read_sql("SELECT Project_id, Project_no, Customer_id, Requested_amount, Status FROM project WHERE (Rating IS NULL OR Rating = '')", conn)

with st.container(border=True):
    st.write("**Pending Underwriting Queue**")
    st.dataframe(df_todo, use_container_width=True, height=200)
    
    if not df_todo.empty:
        target_prj = st.selectbox("Select Project for Real-time Scoring:", df_todo['Project_no'])
        
        if st.button("🚀 Start AI Risk Scoring", use_container_width=True):
            with st.spinner("Analyzing Financial Integrity..."):
                prj_data = df_todo[df_todo['Project_no'] == target_prj].iloc[0]
                cursor = conn.cursor(dictionary=True)
                cursor.execute("SELECT Full_report_json FROM financial_data WHERE Customer_id = %s", (int(prj_data['Customer_id']),))
                fin_json = cursor.fetchone()
                
                if fin_json:
                    full_model_path = os.path.join(MODELS_PATH, selected_model)
                    prob, level = run_ml_prediction(fin_json['Full_report_json'], model_path=full_model_path)
                    
                    st.divider()
                    st.subheader("📊 AI Risk Scoring Result")
                    res_c1, res_c2 = st.columns(2)
                    res_c1.metric("Predicted PD", f"{prob:.2%}")
                    res_c2.metric("Calculated Rating", level)
                    
                    # Log traceability for the specific assessment
                    st.caption(f"Governance: Scored by `{selected_model}` using `{csv_versions[0]}` snapshot.")
                    
                    # Update MySQL with the new AI rating
                    cursor.execute("UPDATE project SET Rating = %s WHERE Project_no = %s", (level, target_prj))
                    conn.commit()
                    st.success("Risk assessment successfully archived to database.")
                else: st.error("Inference failed: Feature set not found in DB.")
    else:
        st.info("Assessment queue is empty.")

# --- [6. Section 2: Management & Governance Console] ---
st.markdown("<br>", unsafe_allow_html=True)
with st.expander("🔧 Advanced Model Governance (Admin Console)"):
    tab_feedback, tab_snapshots, tab_retrain = st.tabs(["📥 Data Feedback", "📂 Data Snapshots", "🏗️ Model Retraining"])
    
    with tab_feedback:
        st.write("### Business Outcome Feedback")
        
        # PERSISTENCE: Show success message after st.rerun
        if 'sync_success_msg' in st.session_state:
            st.success(st.session_state.sync_success_msg)
            st.balloons()
            del st.session_state.sync_success_msg

        # --- [1. Optimization: Fetch full customer list for Searchable UI] ---
        try:
            conn_fb = get_db_conn()
            # Fetch Party_name for fuzzy matching, while syncing via Party_id
            query_cust = "SELECT Party_id, Party_name FROM party"
            df_customers = pd.read_sql(query_cust, conn_fb)
            conn_fb.close()
            db_status = True
        except Exception as e:
            df_customers = pd.DataFrame(columns=['Party_id', 'Party_name'])
            db_status = False
            st.error(f"DB Error: {str(e)}")

        with st.form("feedback_form_optimized"):
            if not df_customers.empty:
                # UX: Combine Name and ID for the search dropdown
                cust_options = [f"{row['Party_name']} (ID: {row['Party_id']})" for _, row in df_customers.iterrows()]
                selected_option = st.selectbox("Search & Select Customer:", options=cust_options)
                f_id = re.findall(r'ID: (\d+)', selected_option)[0]
            else:
                f_id = st.text_input("Customer ID (Manual Fallback)", value="")

            f_label = st.selectbox("Actual Outcome", [0, 1], format_func=lambda x: "Normal (0)" if x==0 else "Bankrupt (1)")
            
            # --- [2. Feedback Submission Logic with Rerun] ---
            if st.form_submit_button("📤 Sync to Data Lake"):
                if f_id:
                    with st.spinner("Archiving operational data to Azure..."):
                        success, msg = sync_to_azure(f_id, f_label, csv_versions[0])
                        if success: 
                            # Cache message and trigger rerun to refresh Snapshot/Training lists
                            st.session_state.sync_success_msg = f"Feedback archived! New Snapshot: {msg}"
                            st.rerun()
                        else: st.error(msg)
                else: st.warning("ID is required.")
                
    with tab_snapshots:
        st.write("### Snapshot Lineage Management")
        if csv_versions:
            st.write(f"Archive Size: {len(csv_versions)} snapshots found.")
            st.dataframe(pd.DataFrame({"Archived Filename": csv_versions}), use_container_width=True)
        else: st.warning("No snapshots detected in Data Lake.")
        
    with tab_retrain:
        st.write("### Model Training Console")
        
        # PERSISTENCE: Post-rerun training success message
        if 'train_success_msg' in st.session_state:
            st.success(st.session_state.train_success_msg)
            st.warning("⚠️ **Note:** New model registered. Activate manually in the sidebar to deploy.")
            del st.session_state.train_success_msg

        if csv_versions:
            sel_train_data = st.selectbox("Select Baseline for Training:", csv_versions)
            
            if st.button("▶ Trigger MLOps Pipeline", use_container_width=True):
                with st.spinner("Fitting Random Forest Model..."):
                    cmd = [sys.executable, "retrain_model.py", "--data", sel_train_data]
                    result = subprocess.run(cmd, capture_output=True, text=True, cwd=BASE_PATH)
                    
                    if result.returncode == 0:
                        output_msg = result.stdout.strip()
                        m_name = output_msg.split("SUCCESS:")[-1].strip() if "SUCCESS:" in output_msg else "New Model"
                        st.session_state.train_success_msg = f"✅ Training Successful: `{m_name}`"
                        st.rerun() # Refresh sidebar to show new model version
                    else:
                        st.error("Pipeline Error"); st.code(result.stderr)

conn.close()