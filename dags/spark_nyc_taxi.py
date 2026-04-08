from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import SparkKubernetesOperator
from airflow.providers.cncf.kubernetes.sensors.spark_kubernetes import SparkKubernetesSensor
from airflow.utils.trigger_rule import TriggerRule
from airflow import AirflowException
import logging

log = logging.getLogger(__name__)


def cleanup_spark_application(context):
    """
    On failure, log the failed SparkApplication name so it can be manually
    or automatically cleaned up. Extend this to call the K8s API if needed.
    """
    ti = context["task_instance"]
    try:
        app_meta = ti.xcom_pull(task_ids="submit_nyc_taxi_aggregation")
        if app_meta:
            app_name = app_meta["metadata"]["name"]
            log.error(
                "SparkApplication '%s' may be orphaned in namespace 'spark'. "
                "Manual cleanup: kubectl delete sparkapplication %s -n spark",
                app_name,
                app_name,
            )
    except Exception as e:
        log.warning("Could not retrieve SparkApplication name for cleanup: %s", e)


with DAG(
    dag_id="spark_nyc_taxi",
    start_date=datetime(2024, 1, 1),
    # Airflow 2.4+: use `schedule` instead of deprecated `schedule_interval`
    schedule=None,
    catchup=False,
    tags=["spark", "demo"],
    # Hard ceiling for the entire DAG run
    dagrun_timeout=timedelta(hours=3),
    default_args={
        "owner": "data-engineering",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
        # Covers the submit call itself, not the Spark job runtime
        "execution_timeout": timedelta(minutes=10),
        "on_failure_callback": cleanup_spark_application,
    },
) as dag:

    submit = SparkKubernetesOperator(
        task_id="submit_nyc_taxi_aggregation",
        application_file="spark_nyc_taxi_application.yaml",
        namespace="spark",
        kubernetes_conn_id="kubernetes_default",
        do_xcom_push=True,
    )

    monitor = SparkKubernetesSensor(
        task_id="monitor_nyc_taxi_aggregation",
        namespace="spark",
        application_name=(
            "{{ task_instance.xcom_pull("
            "task_ids='submit_nyc_taxi_aggregation')['metadata']['name'] }}"
        ),
        kubernetes_conn_id="kubernetes_default",
        # Karpenter needs time to provision nodes before pods are scheduled.
        # 5 min covers typical cold-start (node registration + kubelet ready).
        # Increase to 8-10 min if using larger instance types or spot with low
        # availability, or if your Spark image pull is slow on a fresh node.
        poke_interval=60,       # poll every 60s — no point hammering K8s API
        timeout=7200,           # 2h hard stop for the Spark job itself
        soft_fail=False,        # treat timeout as a real failure
        attach_log=True,        # stream driver logs into Airflow task logs
        # Give Karpenter time: sensor starts immediately after submit,
        # but the pod won't be Running until the node is provisioned.
        # `mode=reschedule` releases the worker slot between pokes — important
        # if you have many concurrent DAG runs or a small Celery/K8s executor pool.
        mode="reschedule",
    )

    submit >> monitor