---
title: "Grafana"
tags: [모니터링]
status: published
---

다양한 데이터 소스(Prometheus, Loki 등)에 연결해 [[메트릭]]과 [[로그]]를 시각화하는 오픈소스 대시보드 도구입니다.

## 핵심 특징

- **다중 데이터 소스**: Prometheus, Loki, Elasticsearch, MySQL 등 50+ 지원
- **대시보드**: 패널 단위로 구성, 팀과 공유 가능
- **알림(Alert)**: 임계값 초과 시 Slack, 이메일, PagerDuty 등으로 알림
- **Explore 모드**: 대시보드 없이 즉석 쿼리/탐색

## 패널 유형

| 패널 | 용도 |
|---|---|
| Time series | CPU, 메모리, 응답 시간 추이 |
| Gauge | 현재 값 (CPU 사용률 72%) |
| Stat | 단일 숫자 강조 (총 요청 수) |
| Table | 다차원 데이터 테이블 |
| Heatmap | 응답 시간 분포 시각화 |
| Logs | [[Loki]] 로그 스트림 |

## Spring Boot 연동 (Prometheus + Grafana)

```xml
<!-- build.gradle -->
implementation 'org.springframework.boot:spring-boot-starter-actuator'
implementation 'io.micrometer:micrometer-registry-prometheus'
```

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: prometheus, health
  metrics:
    tags:
      application: cslog-backend
```

```
# /actuator/prometheus 엔드포인트 노출
http_server_requests_seconds_count{method="GET",uri="/api/posts"} 1234
jvm_memory_used_bytes{area="heap"} 1.5e+08
```

```yaml
# prometheus.yml — 스크랩 설정
scrape_configs:
  - job_name: 'cslog-backend'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['localhost:8080']
```

## 알림 설정 흐름

```
Grafana Alert Rule
   └─ 쿼리 조건 평가 (예: avg(cpu) > 80)
        └─ 임계값 초과 시
             └─ Contact Point (Slack/Email) 발송
```

→ [[Grafana & Loki]]
