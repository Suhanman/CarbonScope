
resource "aws_sns_topic" "alerts" {
  name = "offsets-carbon-alerts"
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "victor1919@naver.com"  # 실제 받을 이메일 주소
}
