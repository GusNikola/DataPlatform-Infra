from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("NycTaxiTripStats").getOrCreate()

df = spark.read.parquet("s3a://dataplatform-dev-data-866376946262/raw/nyc-taxi/")

result = (
    df
    .filter(F.col("tpep_dropoff_datetime") > F.col("tpep_pickup_datetime"))
    .filter(F.col("trip_distance") > 0)
    .withColumn(
        "duration_minutes",
        (F.unix_timestamp("tpep_dropoff_datetime") - F.unix_timestamp("tpep_pickup_datetime")) / 60,
    )
    .filter(F.col("duration_minutes").between(1, 180))
    .withColumn("speed_mph", F.col("trip_distance") / (F.col("duration_minutes") / 60))
    .withColumn(
        "distance_segment",
        F.when(F.col("trip_distance") < 1, "short")
        .when(F.col("trip_distance") < 5, "medium")
        .otherwise("long"),
    )
    .withColumn("pickup_hour", F.hour("tpep_pickup_datetime"))
    .groupBy("distance_segment", "pickup_hour")
    .agg(
        F.count("*").alias("trip_count"),
        F.avg("duration_minutes").alias("avg_duration_minutes"),
        F.avg("speed_mph").alias("avg_speed_mph"),
        F.avg("fare_amount").alias("avg_fare"),
        F.percentile_approx("duration_minutes", 0.5).alias("median_duration_minutes"),
    )
    .orderBy("distance_segment", "pickup_hour")
)

result.write.mode("overwrite").parquet(
    "s3a://dataplatform-dev-data-866376946262/processed/nyc-taxi-trip-stats/"
)

spark.stop()
