# Customer Churn Prediction & Data Cleaning App

An interactive Streamlit web application to **predict customer churn**, clean raw datasets, and streamline preprocessing using **Machine Learning** and **SQL-based logic**. This project provides a **user-friendly dashboard** to handle missing values, remove duplicates, and predict churn outcomes based on key customer features.

##  Project Overview

Customer churn refers to when a customer stops doing business with a company. Predicting churn in advance helps businesses proactively retain customers by taking necessary action.

This project focuses on:
- Cleaning and preparing raw customer data
- Handling missing values and duplicates
- Identifying and removing outliers
- Performing batch churn prediction using a pre-trained ML model
- Providing a downloadable cleaned and labeled dataset

Built with **Streamlit** for real-time interaction and visualization.

##  Features

✅ Upload customer data (.csv)  
✅ Handle missing values using mean/median or drop rows  
✅ Fill object columns with `"Unknown"`  
✅ Remove duplicate entries  
✅ Detect and flag outliers in key metrics  
✅ Predict churn using a trained Decision Tree model  
✅ Download cleaned and predicted data as CSV  
✅ Easy-to-use sidebar navigation  


## Tech Stack

- **Python**
- **Streamlit** – For building the web app
- **Pandas** – Data manipulation
- **Scikit-learn** – Model training, scaling, prediction
- **Joblib** – Model and scaler persistence
- **SQL** – Logic and feature engineering (in data preparation stage)
- **Pillow** – Image loading for logo

## Project Structure

├── churn image.jpg
├── decision_tree_model.pkl
├── features1.pkl
├── scaler.pkl
├── project.py # Main Streamlit app
├── requirements.txt
└── sample_data.csv # Optional: test CSV file

##  How to Run the App

### 1. Clone the repository

git clone https://github.com/your-username/customer-churn-prediction-streamlit.git
cd customer-churn-prediction-streamlit

### 2. Install dependencies
pip install -r requirements.txt

### 3. Run the Streamlit app
streamlit run project.py

