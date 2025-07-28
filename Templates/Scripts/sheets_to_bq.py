import gspread
from google.oauth2.service_account import Credentials
import pandas as pd
import os
from google.cloud import bigquery
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)

def transform_custom():
    """
    Fetches and cleans data from Google Sheets.

    Returns:
        DataFrame: Cleaned DataFrame from Google Sheets
    """
    # Use creds to create a client to interact with the Google Drive API
    scope = [
        "https://www.googleapis.com/auth/spreadsheets",
        "https://www.googleapis.com/auth/drive",
    ]
    creds = Credentials.from_service_account_file("key.json", scopes=scope)
    client = gspread.authorize(creds)
    
    # Find a workbook by name and open the first sheet
    try:
        sheet = client.open("").sheet1
    except gspread.SpreadsheetNotFound:
        logging.error("Spreadsheet not found.")
        raise

    # Get all values from the sheet
    try:
        all_values = sheet.get_all_values()
    except Exception as e:
        logging.error(f"Error fetching data from Google Sheets: {e}")
        raise

    # Convert all values to a pandas DataFrame
    df = pd.DataFrame(all_values[1:], columns=all_values[0])

    # Drop columns that are completely empty or consist only of empty strings
    df_cleaned = df.dropna(axis=1, how='all')
    df_cleaned = df_cleaned.loc[:, (df_cleaned != '').any(axis=0)]

    # Handle columns with empty or whitespace column names
    df_cleaned.columns = [col.strip() if col.strip() else f"Unnamed_{i}" for i, col in enumerate(df_cleaned.columns)]

    # Debugging: Log the column names before and after filtering
    logging.info(f"Columns before filtering: {df_cleaned.columns.tolist()}")

    # Remove columns with "Unnamed_" prefix (if they are not needed)
    df_cleaned = df_cleaned.loc[:, ~df_cleaned.columns.str.startswith('Unnamed_')]

    logging.info(f"Columns after filtering: {df_cleaned.columns.tolist()}")

    logging.info("Data transformed successfully.")
    
    return df_cleaned

def export_data_to_big_query(data: pd.DataFrame) -> None:
    """
    Exports data to a BigQuery warehouse.

    Args:
        data (DataFrame): Data to be exported
    """
    table_id = ''
    creds = Credentials.from_service_account_file("key.json")
    client = bigquery.Client(credentials=creds, project='')

    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE
    )
    job = client.load_table_from_dataframe(data, table_id, job_config=job_config)
    job.result()

    logging.info("Data exported to BigQuery successfully.")

if __name__ == "__main__":
    try:
        # Transform data
        df_cleaned = transform_custom()
        
        # Export to BigQuery
        export_data_to_big_query(df_cleaned)
        
        logging.info("Script executed successfully.")
    
    except Exception as e:
        logging.error(f"Script encountered an error: {e}")