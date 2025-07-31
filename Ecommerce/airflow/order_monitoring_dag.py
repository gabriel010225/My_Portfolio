# import os
# import yaml
# import sys
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago
# import snowflake.connector
from datetime import timedelta

default_args = {
    'owner': 'airflow',
    'email': ['admin@example.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
}

AIRFLOW_VENV_ACTIVATE_PATH = "/mnt/c/Users/gabri/PycharmProjects/airflow_venv_312/airflow_global_venv/bin/activate"
DBT_PROJECT_PATH = "/mnt/c/Users/gabri/PycharmProjects/Ecommerce/dbt_ecommerce"


with DAG(
        dag_id='order_monitoring_dag',
        default_args=default_args,
        schedule_interval='@daily',
        start_date=days_ago(1),
        catchup=False
) as dag:
    dbt_run = BashOperator(
        task_id='run_dbt_models',
        bash_command=f'source "{AIRFLOW_VENV_ACTIVATE_PATH}" && cd "{DBT_PROJECT_PATH}" && dbt run --profiles-dir "{DBT_PROJECT_PATH}" --project-dir "{DBT_PROJECT_PATH}"'
    )

    check_orders = BashOperator(
        task_id='check_delayed_orders',
        bash_command=f'source "{AIRFLOW_VENV_ACTIVATE_PATH}" && cd "{DBT_PROJECT_PATH}" && dbt run --profiles-dir "{DBT_PROJECT_PATH}" --project-dir "{DBT_PROJECT_PATH}"'
    )

    dbt_run >> check_orders
