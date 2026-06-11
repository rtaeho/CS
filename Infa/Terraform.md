---
title: "Terraform"
tags: [배포, IaC]
status: published
---

인프라를 코드(HCL)로 선언하고, 클라우드 리소스의 생성·변경·삭제를 자동화하는 IaC(Infrastructure as Code) 도구입니다.

## 왜 필요한가

```
[수동 인프라 관리의 문제]
- 콘솔에서 클릭으로 서버 생성 → 재현 불가, 팀원이 모름
- 환경(개발/스테이징/프로덕션)마다 수동 반복 작업
- 설정 변경 이력 추적 불가

[Terraform]
- 코드로 인프라 선언 → Git으로 버전 관리
- 같은 코드로 여러 환경 동일하게 프로비저닝
- plan으로 변경 사항 미리 확인 후 apply
```

## 핵심 특징

- **선언형**: 원하는 최종 상태를 선언 → Terraform이 현재 상태와 비교해 필요한 작업 수행
- **멱등성**: 같은 코드를 여러 번 실행해도 동일한 결과
- **멀티 클라우드**: GCP, AWS, Azure, Kubernetes 등 Provider로 통합 관리
- **State 파일**: 현재 인프라 상태를 `.tfstate`로 추적

## 기본 작동 흐름

```
.tf 파일 작성
    │
    ▼
terraform init      ← Provider 플러그인 다운로드
    │
    ▼
terraform plan      ← 변경 사항 미리 보기 (dry-run)
    │
    ▼
terraform apply     ← 실제 리소스 생성/변경/삭제
    │
    ▼
terraform destroy   ← 모든 리소스 삭제
```

## HCL 문법 예시 (GCP Cloud Run)

```hcl
# provider 설정
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "cslog-rtaeho"
  region  = "asia-northeast3"
}

# Cloud Run 서비스 생성
resource "google_cloud_run_v2_service" "backend" {
  name     = "cslog-backend"
  location = "asia-northeast3"

  template {
    containers {
      image = "asia-northeast3-docker.pkg.dev/cslog-rtaeho/cslog/backend:latest"

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }
}

# 외부 접근 허용
resource "google_cloud_run_v2_service_iam_member" "public" {
  name   = google_cloud_run_v2_service.backend.name
  role   = "roles/run.invoker"
  member = "allUsers"
}

# 출력값
output "backend_url" {
  value = google_cloud_run_v2_service.backend.uri
}
```

## 핵심 블록

| 블록 | 역할 |
|---|---|
| `terraform` | 버전, provider 선언 |
| `provider` | 클라우드 연결 설정 |
| `resource` | 생성할 인프라 리소스 |
| `variable` | 입력값 (환경별 값 분리) |
| `output` | 생성 후 출력할 값 |
| `data` | 기존 리소스 참조 |
| `module` | 재사용 가능한 코드 묶음 |

## State 관리

```
[로컬 state — 개발용]
terraform.tfstate 파일을 로컬에 저장
→ 팀 협업 시 충돌 위험

[원격 state — 팀 협업]
GCS 버킷 or Terraform Cloud에 저장
→ 동시 수정 방지 (State Locking)

terraform {
  backend "gcs" {
    bucket = "cslog-terraform-state"
    prefix = "prod"
  }
}
```

## Ansible vs Terraform

| 항목 | Terraform | Ansible |
|---|---|---|
| 목적 | 인프라 프로비저닝 | 서버 설정·소프트웨어 설치 |
| 방식 | 선언형 | 절차형 |
| 상태 관리 | State 파일로 추적 | 없음 |
| 주요 대상 | Cloud 리소스 (VM, DB, 네트워크) | OS 설정, 패키지 설치 |
