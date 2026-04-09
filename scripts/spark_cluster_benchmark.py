import random
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("SparkClusterBenchmark").getOrCreate()
sc = spark.sparkContext

num_samples = 10_000_000

def inside(_):
    x, y = random.random(), random.random()
    return x * x + y * y < 1.0

count = sc.parallelize(range(num_samples)).filter(inside).count()
pi = 4.0 * count / num_samples

print(f"Pi estimate: {pi:.6f} (samples: {num_samples:,}, inside: {count:,})")

spark.stop()
