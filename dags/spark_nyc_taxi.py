from datetime import datetime, timedelta
import logging

from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import SparkKubernetesOperator

log = logging.getLogger(__name__)


with DAG(
    dag_id="spark_nyc_taxi",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["spark", "demo"],
    dagrun_timeout=timedelta(hours=3),
    default_args={
        "owner": "data-engineering",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
        # Covers node provisioning (~90s) + job runtime (~3min) + buffer
        "execution_timeout": timedelta(minutes=30),
    },
) as dag:

    SparkKubernetesOperator(
        task_id="run_nyc_taxi_aggregation",
        application_file="spark_nyc_taxi_application.yaml",
        namespace="spark",
        kubernetes_conn_id="kubernetes_default",
        # do_xcom_push=False prevents the XCom sidecar bug in cncf.kubernetes
        # provider where await_xcom_sidecar_container_start crashes with TypeError
        # on the Spark driver pod (which has no xcom sidecar container).
        # The operator monitors the driver pod to completion via KubernetesPodOperator.
        do_xcom_push=False,
    )
