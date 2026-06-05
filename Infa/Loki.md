로그를 레이블 기반으로 인덱싱해 저장하는 경량 로그 집계 시스템으로, Grafana Labs가 만들었으며 [[Grafana]]와 함께 사용합니다.

## 핵심 특징

- **레이블 인덱싱**: 로그 본문은 인덱싱하지 않고 메타데이터(레이블)만 인덱싱 → 저장 비용 최소화
- **Prometheus와 동일한 레이블 모델**: 같은 레이블로 [[메트릭]]↔[[로그]] 연계 가능
- **LogQL**: Loki 전용 쿼리 언어 (Prometheus PromQL과 유사)
- **Promtail**: 로그 수집 에이전트 (파일/컨테이너 로그 → Loki 전송)

## ELK vs PLG 비교

| 항목 | ELK (Elasticsearch + Logstash + Kibana) | PLG (Promtail + Loki + Grafana) |
|---|---|---|
| 인덱싱 | 전체 텍스트 인덱싱 | 레이블만 인덱싱 |
| 검색 속도 | 빠름 | 상대적으로 느림 |
| 저장 비용 | 높음 | 낮음 |
| 운영 복잡도 | 높음 | 낮음 |
| 메트릭 연동 | 별도 설정 필요 | Prometheus와 자연스럽게 통합 |

## 로그 수집 흐름

```
Spring Boot 앱
     │ 로그 파일 (stdout / file)
     ▼
  Promtail (로그 에이전트)
     │ 레이블 부착 {app="cslog", env="prod"}
     ▼
   Loki (저장)
     │ LogQL 쿼리
     ▼
  Grafana (시각화)
```

## LogQL 기본 문법

```logql
# 레이블 필터 — cslog 앱의 ERROR 로그
{app="cslog"} |= "ERROR"

# 정규식 필터
{app="cslog"} |~ "userId=\\d+"

# 로그 라인 파싱 후 필터
{app="cslog"} | logfmt | level="error"

# 초당 에러 로그 수 (메트릭으로 변환)
rate({app="cslog"} |= "ERROR" [1m])
```

## Docker Compose 설정 예시

```yaml
services:
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log
      - ./promtail-config.yml:/etc/promtail/config.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
```

→ [[Grafana & Loki]]
