# CarbonScope
카본스코프

<img width="801" height="449" alt="image" src="https://github.com/user-attachments/assets/cd31fae4-f7be-4c51-86ff-c21a700729fc" />


2025.11~2025.12

<img width="797" height="452" alt="image" src="https://github.com/user-attachments/assets/447d12d4-37f2-4a67-9717-66cb4cc662df" />


팀원 : 도현직 / 박수한 / 안제현 / 박건우

담당 : 클라우드 인프라 설계 및 데이터 CronJob 수행 및 데이터 통합 관리

개발 기간 : 09.15 ~ 11.26


CarbonScope 프로젝트에서의 Role에 대하여

본 프로젝트에서 본인이 담당한 도메인은 크게 다음과 같다.

1. AWS 퍼블릭 클라우드를 이용한 서버 인프라의 구축 및 서버와 웹의 배포

2. CSV로 받아온 통합 데이터의 RDS로의 Cron 수행

3. RDS로의 데이터 통합 작업 및 Batch Job 의 로그 기반 모니터링 구축

<구현 과정 및 방법>

1. AWS 퍼블릭 클라우드를 이용한 서버 인프라의 구축 및 서버와 웹의 배포

<img width="1905" height="1187" alt="image" src="https://github.com/user-attachments/assets/6f89b283-8545-4ccd-858b-5ed37895fed2" />


기본적으로 Terraform을 통한 Iac 방식을 이용하는 것을 원칙으로 한다.
Terraform 으로 작성된 Iac는 Module화를 기본 전제로 하나의 Module에는 main/variable/outputs 의 tf파일을 전제로 한다.

본 프로젝트는 웹 구성에 필요한 최소한의 인프라 자원을 사용하는 것을 목표로 하였다.

VPC

subnet

igw

route

nat

sg

key

instance

RDS

CloudWatch

SNS



<img width="1778" height="936" alt="image" src="https://github.com/user-attachments/assets/f7a152cc-8c2a-40df-be9d-2886aeb24662" />


