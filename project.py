import streamlit as st
import pandas as pd
import joblib
from PIL import Image

#  Set page configuration at the top
st.set_page_config(page_title="Customer Churn & Data Cleaning App", layout="wide")

# Load and display logo
logo = Image.open("churn image.jpg")
st.image(logo, width=350)  # You can adjust the width


# Load model, features, and scaler
model = joblib.load('decision_tree_model.pkl')
features = joblib.load('features1.pkl')
scaler = joblib.load('scaler.pkl')


st.sidebar.title("📂 Navigation")
section = st.sidebar.radio("Go to:", [
    "customer_churn _prediction_img",
    "Handle Missing Values",
    "Remove Duplicates",
    "Customer Churn Prediction"
])

st.title("🧹 Customer Data Cleaning & Churn Prediction App")

uploaded_file = st.sidebar.file_uploader("Upload CSV file", type=["csv"])

required_columns = ['Age', 'Annual_Income', 'Total_Spend',
                    'Num_of_Purchases', 'Average_Transaction_Amount',
                    'Last_Purchase_Days_Ago']
allowed_columns = required_columns + ['Target_Churn']

if "cleaned_df" not in st.session_state and uploaded_file is not None:
    st.session_state.cleaned_df = pd.read_csv(uploaded_file)
    st.session_state.original_df = st.session_state.cleaned_df.copy()

if "cleaned_df" in st.session_state:
    df = st.session_state.cleaned_df
    original_df = st.session_state.original_df

    # Common column validation
    extra_columns = set(df.columns) - set(allowed_columns)
    if extra_columns:
        st.error(f"❌ Please remove the extra column(s): {', '.join(extra_columns)}")
    else:
        if section == "Handle Missing Values":
            st.subheader("🧩 Handle Missing Values")
            st.write("### Missing Value Count:")
            st.write(df.isnull().sum())

            strategy = st.selectbox("Select imputation strategy for numeric columns:", ["None", "Mean", "Median"])

            if strategy != "None":
                num_cols = df.select_dtypes(include=['float64', 'int64']).columns
                for col in num_cols:
                    if df[col].isnull().sum() > 0:
                        if strategy == "Mean":
                            df[col]= df[col].fillna(df[col].mean())
                        elif strategy == "Median":
                            df[col].fillna(df[col].median(), inplace=True)
                st.success(f"✅ Missing numeric values filled with {strategy.lower()}.")

            if st.button("Fill missing values in object columns with 'Unknown'"):
                for col in df.select_dtypes(include='object').columns:
                    df[col].fillna("Unknown", inplace=True)
                st.success("✅ Missing object values filled with 'Unknown'.")

            if st.button("Drop rows with any remaining missing values"):
                before = len(df)
                df.dropna(inplace=True)
                after = len(df)
                st.success(f"🗑️ Dropped {before - after} rows with remaining missing values.")

            st.write("### Updated Data Preview")
            st.dataframe(df.head())

        elif section == "Remove Duplicates":
            st.subheader("📑 Remove Duplicates")
            before = len(df)
            df.drop_duplicates(inplace=True)
            after = len(df)
            st.success(f"Removed {before - after} duplicate rows.")
            st.dataframe(df.head())

        elif section == "Customer Churn Prediction":
            st.subheader("🧠 Customer Churn Prediction")

            missing = set(required_columns) - set(df.columns)

            if missing:
                st.error(f"❌ The uploaded file is missing required columns: {', '.join(missing)}")
            else:
                df = df[required_columns]
                st.info("ℹ️ Only required columns were used for prediction. Extra columns (except 'Target_Churn') were ignored.")

                # Step 1: Drop duplicates
                before_dup = len(df)
                df.drop_duplicates(inplace=True)
                after_dup = len(df)
                dup_dropped = before_dup - after_dup

                # Step 2: Impute missing values using Mean
                for col in required_columns:
                    if df[col].isnull().sum() > 0:
                        df[col].fillna(df[col].mean(), inplace=True)

                # Step 3: Drop remaining missing rows
                before_na = len(df)
                df.dropna(inplace=True)
                after_na = len(df)
                na_dropped = before_na - after_na

                st.info(f"🧹 Removed {dup_dropped} duplicate rows and {na_dropped} rows with missing values (after imputation).")

                if len(df) == 0:
                    st.warning("⚠️ No rows left after cleaning. Please upload a valid dataset.")
                else:
                    # Step 4: Check for outliers
                    max_values = {
                        'Age': 120,
                        'Annual_Income': 1_000_000,
                        'Total_Spend': 500_000,
                        'Num_of_Purchases': 1000,
                        'Average_Transaction_Amount': 100_000,
                        'Last_Purchase_Days_Ago': 3650
                    }

                    outlier_columns = []
                    for col, max_val in max_values.items():
                        if (df[col] > max_val).any():
                            outlier_columns.append(f"{col} (max allowed: {max_val})")

                    if outlier_columns:
                        st.error("❌ The following columns contain outlier values that exceed allowed limits:\n\n" +
                                 "\n".join(outlier_columns) +
                                 "\n\nPlease fix these values in your file and try again.")
                    else:
                        try:
                            X_input = df[required_columns]
                            X_scaled = scaler.transform(X_input)
                            predictions = model.predict(X_scaled)
                            df['Target_Churn'] = predictions

                            st.success("🎯 Predictions completed successfully!")
                            st.write("### 📊 Cleaned Data with Predictions")
                            st.dataframe(df)

                            csv = df.to_csv(index=False).encode('utf-8')
                            st.download_button("📥 Download Cleaned Predictions as CSV", csv, "predicted_cleaned_churn.csv", "text/csv")

                        except Exception as e:
                            st.error(f"❌ Error during batch prediction: {e}")

      