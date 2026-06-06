신규 버전을 전체가 아닌 일부 트래픽에만 먼저 노출해 위험을 최소화하며 점진적으로 릴리즈하는 배포 전략입니다.

## 개념

이름의 유래: 광부들이 탄광에서 카나리아 새를 데려가 유해가스를 먼저 감지했던 것처럼, 일부 사용자를 먼저 노출시켜 문제를 조기에 감지합니다.

```
[Canary 배포 흐름]

1단계: 95% 구버전 / 5% 신버전
         ┌──────────────────┐
트래픽 ──┤  Load Balancer   │
         └──────────────────┘
              │         │
           95%│       5%│
              ▼         ▼
         [v1.0 Pod]  [v2.0 Pod]  ← Canary

2단계: 이상 없으면 점진적으로 비율 증가
         20% → 50% → 100%

3단계: 문제 발생 시 즉시 0%로 롤백
```

## Blue-Green vs Canary vs Rolling

| 항목 | [[Blue-Green 배포]] | Canary 배포 | Rolling Update |
|---|---|---|---|
| 전환 방식 | 즉시 100% 전환 | 점진적 비율 증가 | Pod 하나씩 교체 |
| 롤백 속도 | 즉시 (트래픽 스위칭) | 즉시 (비율 0으로) | 느림 |
| 리소스 비용 | 2배 | 소량 추가 | 거의 없음 |
| 위험도 | 낮음 | 가장 낮음 | 중간 |
| 실시간 검증 | 불가 | 가능 | 불가 |

## Kubernetes에서 Canary 구현

```yaml
# 구버전 Deployment (replicas: 9)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cslog-backend-stable
spec:
  replicas: 9
  selector:
    matchLabels:
      app: cslog-backend
      track: stable
  template:
    metadata:
      labels:
        app: cslog-backend
        track: stable
    spec:
      containers:
        - name: backend
          image: cslog/backend:1.0.0
---
# Canary Deployment (replicas: 1) → 전체의 10%
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cslog-backend-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cslog-backend
      track: canary
  template:
    metadata:
      labels:
        app: cslog-backend
        track: canary
    spec:
      containers:
        - name: backend
          image: cslog/backend:2.0.0
---
# Service — label app: cslog-backend 기준으로 양쪽 Pod에 분산
apiVersion: v1
kind: Service
metadata:
  name: cslog-backend-svc
spec:
  selector:
    app: cslog-backend   # track 무관하게 두 Deployment 모두 포함
```

## 언제 사용하나?

- 대규모 사용자 기반에서 새 기능의 안정성을 검증할 때
- A/B 테스트와 결합해 기능 효과를 측정할 때
- 롤백 비용이 큰 DB 스키마 변경을 동반한 배포
- 새 버전의 성능 · 에러율을 실제 트래픽으로 모니터링

## 핵심 지표 모니터링 (RED)

```
Canary Pod 배포 후 확인:
- Rate:   초당 요청 수 이상 없는지
- Errors: 에러율 증가 없는지
- Duration: 응답 시간 급증 없는지

→ [[Grafana & Loki]]로 실시간 확인
→ 이상 감지 시 canary replicas: 0으로 즉시 롤백
```
