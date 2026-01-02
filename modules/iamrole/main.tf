# 1) EC2가 사용할 IAM Role
resource "aws_iam_role" "app_ec2_role" {
  name = "app-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 2) S3 Put 권한 정책 (네가 준 JSON을 policy로 감싼 것)
resource "aws_iam_role_policy" "app_ec2_s3_policy" {
  name = "app-ec2-s3-put-policy"
  role = aws_iam_role.app_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::vcm-bucket25/*" 
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_agent" {
  name        = "carbon-cloudwatch-agent-policy"
  
  description = "Allow CloudWatch Agent to send logs and metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "app_ec2_attach_cloudwatch" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_agent.arn
}

# 3) EC2에 붙일 Instance Profile
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "app-ec2-instance-profile"
  role = aws_iam_role.app_ec2_role.name
}
