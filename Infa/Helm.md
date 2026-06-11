---
title: "Helm"
tags: [Kubernetes, 배포]
status: published
---

[[Kubernetes]] 애플리케이션을 패키지(Chart) 단위로 관리하는 패키지 매니저로, 복잡한 K8s YAML을 템플릿화하고 환경별 설정을 values.yaml로 분리합니다.

## 왜 필요한가

```
[Helm 없이 Kubernetes 배포]
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
kubectl apply -f configmap.yaml
...

→ 개발/스테이징/프로덕션마다 YAML 파일 중복
→ 버전 관리 어려움
→ 롤백 시 이전 YAML 찾아서 다시 apply

[Helm]
helm install cslog-backend ./cslog-chart -f values-prod.yaml
helm upgrade cslog-backend ./cslog-chart --set image.tag=2.0.0
helm rollback cslog-backend 1
```

## 핵심 개념

| 개념 | 설명 |
|---|---|
| **Chart** | K8s 리소스 템플릿 묶음 (패키지) |
| **Release** | Chart를 클러스터에 설치한 인스턴스 |
| **values.yaml** | 템플릿에 주입할 기본 설정값 |
| **Repository** | Chart를 저장·배포하는 저장소 |

## Chart 디렉토리 구조

```
cslog-backend/
├── Chart.yaml          ← 차트 메타정보 (이름, 버전)
├── values.yaml         ← 기본 설정값
├── values-dev.yaml     ← 개발 환경 오버라이드
├── values-prod.yaml    ← 프로덕션 환경 오버라이드
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    └── configmap.yaml
```

## 템플릿 예시

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-backend
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: backend
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          resources:
            limits:
              cpu: {{ .Values.resources.limits.cpu }}
              memory: {{ .Values.resources.limits.memory }}
```

```yaml
# values.yaml (기본값)
replicaCount: 1

image:
  repository: cslog/backend
  tag: latest

resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
```

```yaml
# values-prod.yaml (프로덕션 오버라이드)
replicaCount: 3

image:
  tag: "1.5.0"

resources:
  limits:
    cpu: "1"
    memory: "1Gi"
```

## 주요 명령어

```bash
# 설치
helm install <release-name> <chart-path> -f values-prod.yaml

# 업그레이드 (없으면 설치)
helm upgrade --install cslog-backend ./cslog-backend \
  --set image.tag=2.0.0 \
  -f values-prod.yaml

# 릴리즈 목록
helm list

# 롤백 (revision 번호로)
helm rollback cslog-backend 2

# 삭제
helm uninstall cslog-backend

# 템플릿 렌더링 확인 (dry-run)
helm template cslog-backend ./cslog-backend -f values-prod.yaml
```

## CI/CD 연동 패턴

```
GitHub Actions
    │
    ├── Docker 이미지 빌드 & 푸시
    │
    └── helm upgrade --install \
            cslog-backend ./helm/cslog-backend \
            --set image.tag=${{ github.sha }} \
            -f helm/values-prod.yaml
```
