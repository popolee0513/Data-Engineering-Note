# import the libraries

from datetime import timedelta
# The DAG object; we'll need this to instantiate a DAG
from airflow import DAG
# Operators; we need this to write tasks!
from airflow.operators.bash_operator import BashOperator
# This makes scheduling easy
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'peter',
    'start_date': days_ago(0),
    'email': ['peter@somemail.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}
dag = DAG(
    'ETL_Server_Access_Log_Processing',
    default_args=default_args,
    description='ETL_Server_Access_Log_Processing',
    schedule_interval=timedelta(days=1),
)
download = BashOperator(
    task_id='download',
    bash_command='wget https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBM-DB0250EN-SkillsNetwork/labs/Apache%20Airflow/Build%20a%20DAG%20using%20Airflow/web-server-access-log.txt',
    dag=dag,
)
extract = BashOperator(
    task_id='extract',
    bash_command='cut -d# web-server-access-log.txt -f 1,4 --output-delimiter=' ' > extract.txt',
    dag=dag,
)
transform = BashOperator(
    task_id='transform',
    bash_command='cat extract.txt | tr a-z A-Z > transform.txt',
    dag=dag,
)

download >> extract >> transform