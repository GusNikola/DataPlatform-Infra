from datetime import datetime
from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import SparkKubernetesOperator
from airflow.providers.cncf.kubernetes.sensors.spark_kubernetes import SparkKubernetesSensor

with DAG(
    dag_id="spark_nyc_taxi",
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["spark", "demo"],
) as dag:

    submit = SparkKubernetesOperator(
        task_id="submit_nyc_taxi_aggregation",
        application_file="/opt/airflow/dags/repo/dags/spark_nyc_taxi_application.yaml",
        namespace="spark",
        kubernetes_conn_id="kubernetes_default",
        do_xcom_push=True,
    )

    monitor = SparkKubernetesSensor(
        task_id="monitor_nyc_taxi_aggregation",
        namespace="spark",
        application_name="{{ task_instance.xcom_pull(task_ids='submit_nyc_taxi_aggregation')['metadata']['name'] }}",
        kubernetes_conn_id="kubernetes_default",
    )

    submit >> monitor
