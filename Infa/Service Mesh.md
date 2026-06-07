[[MSA]]에서 서비스 간 통신을 애플리케이션 코드 변경 없이 인프라 레이어(사이드카 프록시)에서 관리하는 아키텍처 패턴으로, Istio가 대표적인 구현체입니다.

## 왜 필요한가

```
[서비스 수가 늘어날 때의 문제]
- 서비스마다 재시도, 타임아웃, 서킷 브레이커 코드 중복
- 서비스 간 통신 암호화(mTLS) 각자 구현
- 어떤 서비스가 어디로 얼마나 요청하는지 파악 어려움

[Service Mesh]
- 통신 관련 기능을 사이드카 프록시에 위임
- 애플리케이션 코드 변경 없이 적용
```

## 사이드카 패턴

```
[Service Mesh 없을 때]
┌────────────────┐       ┌────────────────┐
│  주문 서비스   │──────▶│  결제 서비스   │
│ (재시도/CB 내장)│       │                │
└────────────────┘       └────────────────┘

[Service Mesh — 사이드카 프록시]
┌──────────────────────┐     ┌──────────────────────┐
│ 주문 서비스          │     │ 결제 서비스          │
│ ┌──────┐ ┌────────┐ │     │ ┌────────┐ ┌──────┐ │
│ │ App  │ │ Envoy  │─┼────▶│─│ Envoy  │ │ App  │ │
│ │      │ │(Proxy) │ │     │ │(Proxy) │ │      │ │
│ └──────┘ └────────┘ │     │ └────────┘ └──────┘ │
└──────────────────────┘     └──────────────────────┘
         ▲                             ▲
         └──────── Control Plane ──────┘
                    (Istiod)
```

## Istio 구성

| 구성 요소 | 역할 |
|---|---|
| **Envoy (Data Plane)** | 각 Pod에 사이드카로 주입, 실제 트래픽 처리 |
| **Istiod (Control Plane)** | 프록시 설정 배포, 인증서 관리, 서비스 디스커버리 |

## 주요 기능

- **트래픽 관리**: 가중치 기반 라우팅 (Canary 배포 90/10), 재시도, 타임아웃, 폴트 주입
- **보안(mTLS)**: 서비스 간 통신 자동 암호화 및 인증 — 코드 변경 없음
- **관찰성**: 서비스 간 모든 트래픽 메트릭·트레이스 자동 수집 ([[Grafana & Loki]] 연동)
- **서킷 브레이커**: [[서킷 브레이커]] 기능을 프록시 레벨에서 일괄 적용

## Istio 트래픽 설정 예시

```yaml
# VirtualService — Canary 트래픽 분배
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: order-service
spec:
  hosts:
    - order-service
  http:
    - route:
        - destination:
            host: order-service
            subset: stable
          weight: 90
        - destination:
            host: order-service
            subset: canary
          weight: 10
---
# DestinationRule — 서브셋 정의
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: order-service
spec:
  host: order-service
  subsets:
    - name: stable
      labels:
        version: v1
    - name: canary
      labels:
        version: v2
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
    outlierDetection:         # 서킷 브레이커
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
```

## API Gateway vs Service Mesh

| 항목 | [[API Gateway]] | Service Mesh |
|---|---|---|
| 위치 | 외부 → 내부 경계 | 내부 서비스 간 |
| 주요 역할 | 인증, 라우팅, Rate Limiting | 재시도, mTLS, 관찰성 |
| 대상 트래픽 | North-South (외부↔내부) | East-West (서비스↔서비스) |
| 코드 변경 | 불필요 | 불필요 |
| 대표 구현체 | Spring Cloud Gateway, Kong | Istio, Linkerd |

실무에서는 둘을 함께 사용합니다 — Gateway가 외부 진입점, Service Mesh가 내부 통신 관리.
