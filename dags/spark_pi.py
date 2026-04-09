from datetime import datetime, timedelta
import logging

from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import SparkKubernetesOperator

log = logging.getLogger(__name__)


with DAG(
    dag_id="spark_pi",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["spark", "test"],
    dagrun_timeout=timedelta(hours=1),
    default_args={
        "owner": "data-engineering",
        "retries": 0,
        "execution_timeout": timedelta(minutes=15),
    },
) as dag:

    SparkKubernetesOperator(
        task_id="run_spark_pi",
        application_file="spark_pi_application.yaml",
        namespace="spark",
        kubernetes_conn_id="kubernetes_default",
        do_xcom_push=False,
        pool="spark_submissions",
    )
