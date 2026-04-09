from datetime import datetime, timedelta
import logging

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import SparkKubernetesOperator

log = logging.getLogger(__name__)

S3_OUTPUT = "s3://dataplatform-dev-data-866376946262/processed/"


def pipeline_summary(**context):
    ti = context["ti"]
    outputs = {
        "hourly_aggregation": f"{S3_OUTPUT}nyc-taxi-hourly/",
        "trip_stats":         f"{S3_OUTPUT}nyc-taxi-trip-stats/",
        "tip_analysis":       f"{S3_OUTPUT}nyc-taxi-tip-analysis/",
    }
    log.info("Pipeline complete. Outputs:")
    for name, path in outputs.items():
        log.info("  %-25s -> %s", name, path)


with DAG(
    dag_id="nyc_taxi_analytics_suite",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["spark", "nyc-taxi"],
    dagrun_timeout=timedelta(hours=3),
    default_args={
        "owner": "data-engineering",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
        "execution_timeout": timedelta(minutes=30),
    },
) as dag:

    hourly_agg = SparkKubernetesOperator(
        task_id="hourly_aggregation",
        application_file="nyc_taxi_hourly_aggregation_application.yaml",
        namespace="spark",
        kubernetes_conn_id="kubernetes_default",
        do_xcom_push=False,
        pool="spark_submissions",
    )

    trip_stats = SparkKubernetesOperator(
        task_id="trip_stats",
        application_file="nyc_taxi_trip_stats_application.yaml",
        namespace="spark",
        kubernetes_conn_id="kubernetes_default",
        do_xcom_push=False,
        pool="spark_submissions",
    )

    tip_analysis = SparkKubernetesOperator(
        task_id="tip_analysis",
        application_file="nyc_taxi_tip_analysis_application.yaml",
        namespace="spark",
        kubernetes_conn_id="kubernetes_default",
        do_xcom_push=False,
        pool="spark_submissions",
    )

    summary = PythonOperator(
        task_id="summary",
        python_callable=pipeline_summary,
    )

    [hourly_agg, trip_stats, tip_analysis] >> summary
