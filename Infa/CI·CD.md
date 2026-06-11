---
title: "CI·CD"
tags: [CI/CD, 배포]
status: published
---

코드 변경이 발생할 때마다 **자동으로 빌드·테스트·배포**까지 이어지는 파이프라인으로, 사람이 개입하지 않아도 안정적으로 릴리즈할 수 있게 해주는 방법론입니다.

## CI vs CD

| | 개념 | 목적 |
|---|---|---|
| **CI** (Continuous Integration) | 코드 병합 시 자동 빌드·테스트 | 버그 조기 발견, 충돌 최소화 |
| **CD** (Continuous Delivery) | 스테이징까지 자동 배포, 운영은 수동 승인 | 언제든 릴리즈 가능한 상태 유지 |
| **CD** (Continuous Deployment) | 운영까지 완전 자동 배포 | 사람 개입 없이 즉시 반영 |

```
[ 파이프라인 흐름 ]

코드 Push
   │
   ▼
CI: 빌드 → 테스트 → 코드 품질 검사
   │
   ▼
CD(Delivery): 스테이징 배포 → QA 확인 → (수동 승인)
   │
   ▼
CD(Deployment): 운영 자동 배포
```

## GitHub Actions

GitHub 내장 CI/CD 도구. `.github/workflows/*.yml`로 파이프라인을 정의.

```yaml
# .github/workflows/deploy.yml

name: Deploy

on:
  push:
    branches: [main]        # main 브랜치 push 시 트리거

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'

      - name: Build with Gradle
        run: ./gradlew build

      - name: Build Docker image
        run: docker build -t my-app:${{ github.sha }} .

      - name: Push to registry
        run: |
          docker tag my-app:${{ github.sha }} gcr.io/my-project/my-app:${{ github.sha }}
          docker push gcr.io/my-project/my-app:${{ github.sha }}

      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy my-app \
            --image gcr.io/my-project/my-app:${{ github.sha }} \
            --region asia-northeast3
```

## 핵심 구성 요소

### Trigger (언제)
```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'   # 매일 새벽 2시
```

### Job · Step (무엇을)
- **Job**: 독립적인 실행 단위, 기본적으로 병렬 실행
- **Step**: Job 내의 순차 실행 단계 (`run` 또는 `uses`)
- `needs: [build]` — Job 간 의존성 정의

### Secret 관리
```yaml
env:
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}   # GitHub Settings → Secrets에 등록
```

## 좋은 CI 파이프라인의 조건

- **빠른 피드백**: 5분 내 결과 — 느리면 개발자가 다른 작업으로 넘어가 버림
- **멱등성**: 같은 코드로 반복 실행해도 결과 동일
- **실패 시 블로킹**: 테스트 실패 시 배포 차단, main 브랜치 보호
- **캐시 활용**: Gradle/Maven 의존성 캐시로 빌드 시간 단축

```yaml
- name: Cache Gradle
  uses: actions/cache@v4
  with:
    path: ~/.gradle/caches
    key: gradle-${{ hashFiles('**/*.gradle*') }}
```

## 주요 CI/CD 도구 비교

| 도구 | 특징 | 적합한 상황 |
|---|---|---|
| GitHub Actions | GitHub 내장, 무료 티어 | 대부분의 오픈소스·스타트업 |
| Jenkins | 자체 서버, 고도 커스터마이징 | 온프레미스 환경, 대기업 |
| GitLab CI | GitLab 내장 | GitLab 사용 팀 |
| CircleCI | 빠른 속도, SaaS | 빌드 속도 중요할 때 |

## 핵심 정리

- **CI**: 코드 합칠 때마다 자동 빌드·테스트 → 버그를 PR 단계에서 잡음

- **CD**: 테스트 통과 시 스테이징(또는 운영)까지 자동 배포 — Delivery(수동 승인)와 Deployment(완전 자동)로 나뉨

- GitHub Actions는 `.github/workflows/*.yml`로 파이프라인 정의, push/PR 이벤트로 트리거

- 시크릿은 코드에 절대 넣지 말고 GitHub Secrets → `${{ secrets.KEY }}` 참조

→ [[Docker]] | [[Blue-Green 배포]] | [[Canary 배포]]

