# CarbonScope (카본스코프)

<img width="2090" height="1153" alt="image" src="https://github.com/user-attachments/assets/7496a0ea-57df-4197-bca4-1c9da22bee5c" />



> **개발 기간**: 2025.09.15 ~ 2025.11.26  
> **운영/정리**: 2025.11 ~ 2025.12  
> **팀원**: 도현직 · 박수한 · 안제현 · 박건우  
> **담당**: 클라우드 인프라 설계 · 데이터 CronJob 수행 · 데이터 통합/모니터링

<img width="2124" height="1181" alt="image" src="https://github.com/user-attachments/assets/d181b022-92ca-4bbc-8e9f-cd2c84c9fb09" />

---

## 1. 담당 Role 요약

1) **AWS 인프라 구축 및 웹/서버 배포** (Terraform IaC, 모듈화 기반)  
2) **CSV → RDS 적재 CronJob(배치) 구성 및 운영**  
3) **Batch 로그 기반 모니터링 구축** (CloudWatch Metric Filter + Alarm + SNS)
4) **CSV와 log의 s3 통합 저장**

---

## 2. 인프라 설계 원칙


<img width="1476" height="902" alt="image" src="https://github.com/user-attachments/assets/c49a6736-f72f-427a-b530-06518ccd7c20" />


- **IaC**: Terraform으로 인프라 전 리소스 선언/관리  
- **모듈화**: 각 모듈은 `main.tf / variables.tf / outputs.tf` 구조  
- **최소 구성**: 웹 운영 + 배치 처리에 필요한 **최소 AWS 리소스**만 사용  
- **비용 고려**: NAT Gateway 대신 **NAT Instance + EIP**로 구성

---

## 3. Terraform Modules (요약 표)

> 루트에서 아래 모듈들을 조합하여 전체 인프라를 구성했습니다.

| Module | Purpose (역할) | Main Resources | Key Inputs (variables) | Outputs |
|---|---|---|---|---|
| **vpc** | 네트워크 기본 골격 | `aws_vpc` | - | `vpc_id` |
| **subnet** | Public/DB Subnet 분리 | `aws_subnet (public/db)` | `vpc_id` | `public_subnet_ids`, `db_subnet_ids` |
| **igw** | Public 인터넷 연결 | `aws_internet_gateway` | `vpc_id` | `igw_id` |
| **route** | 라우팅 구성 (public/private) | `aws_route_table`, `aws_route_table_association` | `vpc_id`, `public_subnet_ids`, `igw_id` | (필요 시 route_table_id 등) |
| **nat** | Private egress 제공 (NAT Instance) | `aws_instance`, `aws_eip`, `aws_eip_association` | `public_subnet_id`, `vpc_id`, `nat_sg_id` | `nat_id`, `nat_network_interface_id` |
| **sg** | 접근 제어 (EC2/RDS) | `aws_security_group (ssh/http/rds)` | `vpc_id`, `public_subnet_ids`, `public_subnet_cidrs` | `ec2_sg_id`, `rds_sg_id` |
| **key** | SSH KeyPair 자동 생성/저장 | `tls_private_key`, `aws_key_pair`, `local_file` | - | `app_key_name`, `app_key_public`, `app_private_key_local_file` |
| **instance** | 앱 서버 배포 단위 | `aws_launch_template`, `aws_instance` | `instance_type`, `public_subnet_ids`, `app_key_name`, `ec2_sg_id`, `app_instance_profile` | (instance_id, public_ip 등 필요 시) |
| **rds** | DB 구축 | `aws_db_subnet_group`, `aws_db_instance` | `db_subnet_ids_list`, `rds_sg_id`, `instance_class`, `db_username`, `db_password` | (db_endpoint 등 필요 시) |
| **cloudwatch** | 로그/메트릭/알람 | `aws_cloudwatch_log_group`, `aws_cloudwatch_log_metric_filter`, `aws_cloudwatch_metric_alarm` | `alerts_topic_arn` | (alarm_arn 등 필요 시) |
| **sns** | 알림 채널 구성 | `aws_sns_topic`, `aws_sns_topic_subscription` | (email 등) | `alerts_topic_arn`, `alerts_topic_name`, `alerts_topic_email` |
| **iamrole** | EC2 권한 부여 (S3/CloudWatch) | `aws_iam_role`, `aws_iam_policy`, `aws_iam_instance_profile` | - | `app_instance_profile` |

---

<img width="2033" height="856" alt="image" src="https://github.com/user-attachments/assets/694dc69a-a495-466b-9353-a8a9a07a5fa9" />


## 4. CSV -> RDS CronJob

1. RDS 연결설정

```python
from sqlalchemy import create_engine

engine = create_engine(
    f"mysql+pymysql://{RDS_USER}:{RDS_PW}@{RDS_HOST}/{RDS_DB}?charset=utf8mb4",
    pool_recycle=3600,
)
```

2. CSV 파일로드
   
```python
projects_df = pd.read_csv("projects_for_db.csv")
credits_df  = pd.read_csv("merged_credits.csv")
```
3.  RDS로 Insert
   
```python
projects_df.to_sql(name="projects", con=engine, if_exists="replace", index=False)
credits_df.to_sql(name="credits",  con=engine, if_exists="replace", index=False)
```


---

## 5. 로그 기반 모니터링

데이터 다운로드 -> ec2 안의 CSV와 log 생성 -> S3 업로드
-> CloudWatch Agent 탐지 -> 매트릭 지표 log 탐지 -> 실패/성공 여부의 SNS 알림

**로그 그룹 생성**
```
resource "aws_cloudwatch_log_group" "carbon_log" {
  name              = "/offsets/carbon_log"
  retention_in_days = 30

  tags = {
    Project = "offsets-pipeline"
  }
}
```
로그는 무기한 저장하지 않고 30일 후 자동삭제된다.

**Failed 감지 필터링**
```
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
```
Log Group 내 로그에 JOB_STATUS=FAILED가 포함되면 OffsetsPipeline / CarbonUnifiedJobFailed 메트릭을 1 증가시킨다.

**Failed 알람**
```
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
```
5분(300초) 동안 CarbonUnifiedJobFailed가 합계(Sum) 1 이상이면 ALARM.

실패 로그가 한 번이라도 찍히면(필터가 1 카운트) 5분 내에 알람 기능이 작동.

## 6. S3로의 CSV/log 통합

**로그 파일 생성/회전**

```
LOG_DIR = os.environ.get("APP_LOG_DIR", "/home/ubuntu/logs")
os.makedirs(LOG_DIR, exist_ok=True)

LOG_PATH = os.path.join(LOG_DIR, "s3_worker.log")

logger = logging.getLogger("s3_worker")
logger.setLevel(logging.INFO)

if not logger.handlers:
    file_handler = RotatingFileHandler(
        LOG_PATH,
        maxBytes=5 * 1024 * 1024,
        backupCount=3,
        encoding="utf-8"
    )
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
```
**입력/출력 기본 설정 및 유효성 검증**

```
data_dir = os.environ.get("OUTPUT_DIR", "/home/ubuntu/offsets-data")
log_dir  = os.environ.get("APP_LOG_DIR", "/home/ubuntu/logs")
bucket_name = os.environ.get("S3_BUCKET_NAME", "vcm-bucket25")

if not bucket_name:
    logger.error("S3_BUCKET_NAME 환경변수가 설정되어 있지 않습니다.")
    sys.exit(1)

if not os.path.isdir(data_dir):
    logger.error("데이터 디렉터리가 아닙니다: %s", data_dir)
    sys.exit(1)

if not os.path.isdir(log_dir):
    logger.error("로그 디렉터리가 아닙니다: %s", log_dir)
    sys.exit(1)
```

**저장 경로 규칙 정의**

```
s3 = boto3.client("s3")

today = datetime.utcnow().strftime("%Y-%m-%d")
csv_prefix  = os.environ.get("S3_CSV_PREFIX",  f"csv/{today}")
logs_prefix = os.environ.get("S3_LOG_PREFIX", f"logs/{today}")
```

**업로드 대상 파일 스캔**

```
csv_files = [
    f for f in sorted(os.listdir(data_dir))
    if f.lower().endswith(".csv")
    and os.path.isfile(os.path.join(data_dir, f))
]

log_files = [
    f for f in sorted(os.listdir(log_dir))
    if os.path.isfile(os.path.join(log_dir, f))
]
```
**업로드 작업 리스트 구성**

```
upload_targets = []

for fname in csv_files:
    local_path = os.path.join(data_dir, fname)
    s3_key = f"{csv_prefix}/{fname}"
    upload_targets.append((local_path, s3_key))

for fname in log_files:
    local_path = os.path.join(log_dir, fname)
    s3_key = f"{logs_prefix}/{fname}"
    upload_targets.append((local_path, s3_key))
```
**실제 업로드 루프 및 예외 처리**

```
for local_path, s3_key in upload_targets:
    try:
        logger.info("업로드 시작: %s -> s3://%s/%s", local_path, bucket_name, s3_key)
        s3.upload_file(local_path, bucket_name, s3_key)
        logger.info("업로드 완료: s3://%s/%s", bucket_name, s3_key)
    except (BotoCoreError, ClientError) as e:
        logger.error("업로드 실패: %s -> %s", local_path, e)
```

