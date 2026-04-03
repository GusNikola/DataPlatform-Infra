output "spark_role_arn" {
  description = "ARN of the Spark IRSA role"
  value       = aws_iam_role.spark.arn
}

output "airflow_role_arn" {
  description = "ARN of the Airflow IRSA role"
  value       = aws_iam_role.airflow.arn
}
