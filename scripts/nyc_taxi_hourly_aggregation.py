from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("NycTaxiAggregation").getOrCreate()

df = spark.read.parquet("s3a://dataplatform-dev-data-866376946262/raw/nyc-taxi/")

result = (
    df.withColumn("pickup_hour", F.hour("tpep_pickup_datetime"))
    .groupBy("pickup_hour", "payment_type")
    .agg(
        F.count("*").alias("trip_count"),
        F.avg("fare_amount").alias("avg_fare"),
        F.sum("total_amount").alias("total_revenue"),
        F.avg("trip_distance").alias("avg_distance"),
    )
    .orderBy("pickup_hour", "payment_type")
)

result.write.mode("overwrite").parquet(
    "s3a://dataplatform-dev-data-866376946262/processed/nyc-taxi-hourly/"
)

spark.stop()
