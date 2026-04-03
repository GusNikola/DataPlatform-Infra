output "controller_role_arn" {
  description = "ARN of the Karpenter controller IAM role"
  value       = aws_iam_role.karpenter_controller.arn
}

output "interruption_queue_name" {
  description = "Name of the SQS interruption queue"
  value       = aws_sqs_queue.interruption.name
}
