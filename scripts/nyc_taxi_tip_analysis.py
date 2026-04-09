from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("NycTaxiTipAnalysis").getOrCreate()

df = spark.read.parquet("s3a://dataplatform-dev-data-866376946262/raw/nyc-taxi/")

# payment_type=1 is credit card — the only type with recorded tips
result = (
    df
    .filter(F.col("payment_type") == 1)
    .filter(F.col("fare_amount") > 0)
    .withColumn("tip_pct", F.col("tip_amount") / F.col("fare_amount") * 100)
    .withColumn("pickup_hour", F.hour("tpep_pickup_datetime"))
    .withColumn("day_of_week", F.dayofweek("tpep_pickup_datetime"))
    .groupBy("pickup_hour", "day_of_week")
    .agg(
        F.count("*").alias("trip_count"),
        F.avg("tip_pct").alias("avg_tip_pct"),
        F.avg("tip_amount").alias("avg_tip_amount"),
        F.sum(F.when(F.col("tip_pct") > 20, 1).otherwise(0)).alias("trips_over_20pct_tip"),
        F.max("tip_amount").alias("max_tip"),
    )
    .orderBy("day_of_week", "pickup_hour")
)

result.write.mode("overwrite").parquet(
    "s3a://dataplatform-dev-data-866376946262/processed/nyc-taxi-tip-analysis/"
)

spark.stop()
