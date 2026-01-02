output "alerts_topic_arn" {
  description = "SNS topic ARN for offsets carbon alerts"
  value       = aws_sns_topic.alerts.arn
}

output "alerts_topic_name" {
  description = "SNS topic name"
  value       = aws_sns_topic.alerts.name
}

output "alerts_subscription_email" {
  description = "Email endpoint subscribed to the SNS topic"
  value       = aws_sns_topic_subscription.alerts_email.endpoint
}
