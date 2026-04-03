FROM apache/spark-py:3.5.3

USER root

RUN pip install --no-cache-dir \
    boto3==1.34.0 \
    pyarrow==15.0.0

USER spark
