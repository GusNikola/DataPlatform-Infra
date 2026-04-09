from datetime import datetime, timedelta
import logging

from airflow import DAG
from airflow.operators.python import PythonOperator

log = logging.getLogger(__name__)


def generate_data(**context):
    run_id = context["run_id"]
    log.info("Generating data for run: %s", run_id)
    numbers = list(range(1, 101))
    log.info("Generated %d numbers", len(numbers))
    return numbers


def process_data(**context):
    numbers = context["ti"].xcom_pull(task_ids="generate_data")
    total = sum(numbers)
    average = total / len(numbers)
    log.info("Sum: %d, Average: %.2f", total, average)
    return {"sum": total, "average": average}


def report(**context):
    result = context["ti"].xcom_pull(task_ids="process_data")
    log.info("Final report: sum=%d, average=%.2f", result["sum"], result["average"])


with DAG(
    dag_id="hello_world",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["test"],
    default_args={
        "owner": "data-engineering",
        "retries": 0,
        "execution_timeout": timedelta(minutes=5),
    },
) as dag:

    generate = PythonOperator(
        task_id="generate_data",
        python_callable=generate_data,
    )

    process = PythonOperator(
        task_id="process_data",
        python_callable=process_data,
    )

    report_task = PythonOperator(
        task_id="report",
        python_callable=report,
    )

    generate >> process >> report_task
