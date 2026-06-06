컨테이너화된 애플리케이션의 배포·확장·관리를 자동화하는 오픈소스 컨테이너 오케스트레이션 플랫폼입니다.

## 왜 필요한가

```
[Docker만 사용할 때의 한계]
- 컨테이너가 죽으면 수동으로 재시작해야 함
- 트래픽 증가 시 수동으로 컨테이너 추가
- 여러 서버에 배포하면 관리가 복잡해짐
- 롤링 업데이트, 롤백을 직접 스크립트로 구현

[Kubernetes]
- 컨테이너 자동 재시작 (Self-Healing)
- 트래픽 기반 자동 확장 (HPA)
- 선언형 배포 관리
- 롤링 업데이트 / 롤백 내장
```

## 핵심 구성 요소

```
┌─────────────────────────────────────────────┐
│                 Cluster                      │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │         Control Plane (Master)       │    │
│  │  API Server · etcd · Scheduler       │    │
│  │  Controller Manager                  │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌──────────────┐   ┌──────────────┐        │
│  │   Node 1     │   │   Node 2     │        │
│  │  ┌────────┐  │   │  ┌────────┐  │        │
│  │  │  Pod   │  │   │  │  Pod   │  │        │
│  │  │[컨테이너]│  │   │  │[컨테이너]│  │        │
│  │  └────────┘  │   │  └────────┘  │        │
│  │  kubelet     │   │  kubelet     │        │
│  └──────────────┘   └──────────────┘        │
└─────────────────────────────────────────────┘
```

| 구성 요소 | 역할 |
|---|---|
| **Pod** | 컨테이너 묶음, 배포 최소 단위 |
| **Node** | Pod가 실행되는 물리/가상 서버 |
| **Deployment** | Pod 복제본 수 유지, 롤링 업데이트 관리 |
| **Service** | Pod에 고정 IP/DNS 부여, 로드밸런싱 |
| **Ingress** | 외부 HTTP 트래픽 → Service 라우팅 |
| **ConfigMap / Secret** | 설정값 / 민감 정보 분리 주입 |
| **HPA** | CPU/메모리 기반 Pod 자동 확장 |

## 핵심 오브젝트 YAML 예시

```yaml
# Deployment — 3개 Pod 유지, 롤링 업데이트
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cslog-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: cslog-backend
  template:
    metadata:
      labels:
        app: cslog-backend
    spec:
      containers:
        - name: backend
          image: cslog/backend:1.0.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "500m"
              memory: "1Gi"
```

```yaml
# Service — Pod에 ClusterIP 부여
apiVersion: v1
kind: Service
metadata:
  name: cslog-backend-svc
spec:
  selector:
    app: cslog-backend
  ports:
    - port: 80
      targetPort: 8080
```

## 배포 전략

| 전략 | 설명 | 특징 |
|---|---|---|
| **Rolling Update** | 기본값. 구버전 Pod를 하나씩 교체 | 무중단, 일시적으로 두 버전 공존 |
| **Recreate** | 전체 종료 후 새 버전 시작 | 다운타임 발생 |
| **[[Blue-Green 배포]]** | 두 환경을 동시에 유지, 스위칭 | 리소스 2배 |
| **[[Canary 배포]]** | 일부 트래픽만 새 버전으로 | 점진적 검증 |

## Self-Healing

```
Pod 비정상 종료
      │
      ▼
Controller Manager 감지
      │
      ▼
새 Pod 자동 생성 → replicas 수 유지
```

## kubectl 주요 명령어

```bash
kubectl get pods                          # Pod 목록
kubectl get pods -o wide                  # Node 정보 포함
kubectl describe pod <pod-name>           # Pod 상세 정보
kubectl logs <pod-name>                   # 로그 조회
kubectl apply -f deployment.yaml          # 선언형 배포
kubectl rollout undo deployment/cslog     # 이전 버전 롤백
kubectl scale deployment/cslog --replicas=5  # 수동 스케일
```

## Docker vs Kubernetes

| 항목 | [[Docker]] | Kubernetes |
|---|---|---|
| 역할 | 단일 컨테이너 실행 | 컨테이너 클러스터 관리 |
| 자동 복구 | 없음 | Pod 자동 재시작 |
| 스케일링 | 수동 | HPA 자동 확장 |
| 로드밸런싱 | 수동 구성 | Service 내장 |
| 적합한 규모 | 단일 서버, 개발 환경 | 멀티 서버, 프로덕션 |
