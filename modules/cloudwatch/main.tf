resource "aws_cloudwatch_log_group" "carbon_log" {
  name              = "/offsets/carbon_log"
  retention_in_days = 30

  tags = {
    Project = "offsets-pipeline"
  }
}

resource "aws_cloudwatch_log_metric_filter" "job_success" {
  name           = "carbon_unified_job_success"
  log_group_name = aws_cloudwatch_log_group.carbon_log.name

  # 로그 한 줄 안에 이 문자열이 포함되면 카운트
  pattern = "JOB_STATUS=SUCCESS"

  metric_transformation {
    name      = "CarbonUnifiedJobSuccess"
    namespace = "OffsetsPipeline"
    value     = "1"
    unit      = "Count"
  }
}
resource "aws_cloudwatch_log_metric_filter" "job_failed" {
  name           = "carbon_unified_job_failed"
  log_group_name = aws_cloudwatch_log_group.carbon_log.name

  pattern = "JOB_STATUS=FAILED"

  metric_transformation {
    name      = "CarbonUnifiedJobFailed"
    namespace = "OffsetsPipeline"
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_metric_alarm" "job_failed_alarm" {
  alarm_name          = "carbon-unified-job-failed-alarm"
  alarm_description   = "Offsets carbon_unified_db2 job FAILED detected in logs."
  namespace           = "OffsetsPipeline"
  metric_name         = "CarbonUnifiedJobFailed"
  statistic           = "Sum"
  period              = 300          # 5분
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    var.alerts_topic_arn
  ]

  ok_actions = [
    var.alerts_topic_arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "job_success_alarm" {
  alarm_name          = "carbon-unified-job-success-alarm"
  alarm_description   = "Offsets carbon_unified_db2 job SUCCESS detected in logs."
  namespace           = "OffsetsPipeline"
  metric_name         = "CarbonUnifiedJobSuccess"
  statistic           = "Sum"
  period              = 300           # 5분 동안
  evaluation_periods  = 1
  threshold           = 1

  # ✅ "성공이 감지되면" ALARM 상태가 되도록
  comparison_operator = "GreaterThanOrEqualToThreshold"

  # 성공 로그가 없을 때는 굳이 알람 울리지 않게
  treat_missing_data = "notBreaching"

  alarm_actions = [
    var.alerts_topic_arn
  ]

  ok_actions = [
    var.alerts_topic_arn
  ]
}

