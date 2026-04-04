# IRSA roles for the Spark data platform.
# spark: S3 read/write on the data bucket — used by Spark driver, executor, and History Server pods.
# airflow: S3 read on dags/ prefix, write on airflow-logs/ prefix — used by Airflow scheduler/workers.

resource "aws_iam_role" "spark" {
  name = "${var.cluster_name}-spark-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:spark:spark"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "spark" {
  name = "${var.cluster_name}-spark-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SparkS3ReadWrite"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ]
        Resource = [
          var.data_bucket_arn,
          "${var.data_bucket_arn}/*",
        ]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "spark" {
  role       = aws_iam_role.spark.name
  policy_arn = aws_iam_policy.spark.arn
}

resource "aws_iam_role" "airflow" {
  name = "${var.cluster_name}-airflow-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Condition = {
        StringLike = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:airflow:airflow*"
        }
        StringEquals = {
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "airflow" {
  name = "${var.cluster_name}-airflow-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AirflowS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ]
        Resource = [
          var.data_bucket_arn,
          "${var.data_bucket_arn}/dags/*",
          "${var.data_bucket_arn}/airflow-logs/*",
        ]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "airflow" {
  role       = aws_iam_role.airflow.name
  policy_arn = aws_iam_policy.airflow.arn
}
