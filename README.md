# CarbonScope (카본스코프)

> **개발 기간**: 2025.09.15 ~ 2025.11.26  
> **운영/정리**: 2025.11 ~ 2025.12  
> **팀원**: 도현직 · 박수한 · 안제현 · 박건우  
> **담당**: 클라우드 인프라 설계 · 데이터 CronJob 수행 · 데이터 통합/모니터링

---

## 1. 담당 Role 요약

1) **AWS 인프라 구축 및 웹/서버 배포** (Terraform IaC, 모듈화 기반)  
2) **CSV → RDS 적재 CronJob(배치) 구성 및 운영**  
3) **Batch 로그 기반 모니터링 구축** (CloudWatch Metric Filter + Alarm + SNS)

---

## 2. 인프라 설계 원칙

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
| **subnet** | Public/DB Subnet 분리 | `aws_subnet` (public/db) | `vpc_id` | `public_subnet_ids`, `db_subnet_ids` |
| **igw** | Public 인터넷 연결 | `aws_internet_gateway` | `vpc_id` | `igw_id` |
| **route** | 라우팅 구성 (public/private) | `aws_route_table`, `aws_route_table_association` | `vpc_id`, `public_subnet_ids`, `igw_id` | (필요 시 route_table_id 등) |
| **nat** | Private egress 제공 (NAT Instance) | `aws_instance`, `aws_eip`, `aws_eip_association` | `public_subnet_id`, `vpc_id`, `nat_sg_id` | `nat_id`, `nat_network_interface_id` |
| **sg** | 접근 제어 (EC2/RDS) | `aws_security_group` (ssh/http/rds) | `vpc_id`, `public_subnet_ids`, `public_subnet_cidrs` | `ec2_sg_id`, `rds_sg_id` |
| **key** | SSH KeyPair 자동 생성/저장 | `tls_private_key`, `aws_key_pair`, `local_file` | - | `app_key_name`, `app_key_public`, `app_private_key_local_file` |
| **instance** | 앱 서버 배포 단위 | `aws_launch_template`, `aws_instance` | `instance_type`, `public_subnet_ids`, `app_key_name`, `ec2_sg_id`, `app_instance_profile` | (instance_id, public_ip 등 필요 시) |
| **rds** | DB 구축 | `aws_db_subnet_group`, `aws_db_instance` | `db_subnet_ids_list`, `rds_sg_id`, `instance_class`, `db_username`, `db_password` | (db_endpoint 등 필요 시) |
| **cloudwatch** | 로그/메트릭/알람 | `aws_cloudwatch_log_group`, `aws_cloudwatch_log_metric_filter`, `aws_cloudwatch_metric_alarm` | `alerts_topic_arn` | (alarm_arn 등 필요 시) |
| **sns** | 알림 채널 구성 | `aws_sns_topic`, `aws_sns_topic_subscription` | (email 등) | `alerts_topic_arn`, `alerts_topic_name`, `alerts_topic_email` |
| **iamrole** | EC2 권한 부여 (S3/CloudWatch) | `aws_iam_role`, `aws_iam_policy`, `aws_iam_instance_profile` | - | `app_instance_profile` |

---

## 4. 핵심 구현 포인트

- **Terraform 모듈화**로 네트워크/보안/컴퓨팅/DB/모니터링을 분리하여 재사용성과 유지보수성 확보  
- **CSV → RDS CronJob** 기반 적재 파이프라인 운영 (통합 데이터 일괄 적재)  
- **CloudWatch 로그 기반 관측성 확보**  
  - Log Group 수집  
  - Metric Filter로 실패/에러 패턴 카운트  
  - Alarm 발생 시 SNS 이메일 알림

---

## 5. 아키텍처 이미지 (선택)

> GitHub에서 렌더링되도록 아래처럼 링크를 붙이면 가독성이 좋습니다.

```markdown
![architecture](https://github.com/user-attachments/assets/6f89b283-8545-4ccd-858b-5ed37895fed2)
