---
title: "Rate Limiting"
tags: [보안, APIGateway]
status: published
---

서버가 처리할 수 있는 요청 수를 제한해 과부하·DDoS를 방지하고 공정한 자원 사용을 보장하는 기법입니다.

## 주요 알고리즘

### Fixed Window Counter

```
[1분 창 단위로 카운트]

0:00─────────0:59 | 1:00─────────1:59
  요청: 100개       요청: 100개

→ 구현 단순
→ 경계 버스트 문제: 0:59에 100개 + 1:00에 100개 = 2초에 200개
```

### Sliding Window Log

```
현재 시각 기준 지난 1분의 요청 로그를 보관
→ 정밀하지만 메모리 사용량 큼
```

### Sliding Window Counter

```
Fixed Window의 경계 버스트를 완화
현재 창 카운트 + 이전 창 카운트 × (남은 비율)로 추정

예) 이전 창 80개, 현재 창 30개, 70% 지남
→ 추정치 = 30 + 80 × 0.3 = 54개
```

### Token Bucket

```
[토큰 버킷]
                    ┌─────────┐
토큰 충전 (1/초) ──▶│  버킷   │ 최대 N개
                    └────┬────┘
                         │ 요청 시 토큰 1개 소비
                         ▼
                    토큰 없으면 → 거부 or 대기

→ 버스트 허용 (토큰이 쌓여있으면 순간 다량 처리 가능)
→ AWS API Gateway 기본 방식
```

### Leaky Bucket

```
[누수 버킷]
요청 ──▶ [   버킷 큐   ] ──▶ 일정 속도로 처리 (rate)
           버킷이 가득 차면 → 거부

→ 출력 속도 일정 보장 (트래픽 평탄화)
→ 버스트 흡수는 하지만 처리 지연 발생
```

## 알고리즘 비교

| 알고리즘 | 버스트 허용 | 구현 복잡도 | 메모리 | 특징 |
|---|---|---|---|---|
| Fixed Window | △ (경계 버스트) | 낮음 | 낮음 | 단순, 경계 취약 |
| Sliding Window Log | O 정밀 | 높음 | 높음 | 정확하지만 비쌈 |
| Sliding Window Counter | O 근사 | 중간 | 낮음 | 실무 추천 |
| Token Bucket | O | 중간 | 낮음 | 버스트 허용 |
| Leaky Bucket | X | 중간 | 중간 | 출력 속도 일정 |

## Spring Boot + Redis 구현

```java
// build.gradle
implementation 'org.springframework.boot:spring-boot-starter-data-redis'
implementation 'org.springframework.cloud:spring-cloud-starter-gateway'
```

```yaml
# application.yml — Spring Cloud Gateway Rate Limiter
spring:
  cloud:
    gateway:
      routes:
        - id: api
          uri: http://backend:8080
          filters:
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 10   # 초당 토큰 충전
                redis-rate-limiter.burstCapacity: 20   # 버킷 최대 용량
                redis-rate-limiter.requestedTokens: 1  # 요청당 소비 토큰
                key-resolver: "#{@ipKeyResolver}"
```

```java
// IP 기반 Key Resolver
@Bean
public KeyResolver ipKeyResolver() {
    return exchange -> Mono.just(
        exchange.getRequest().getRemoteAddress().getAddress().getHostAddress()
    );
}
```

## 응답 처리

```
429 Too Many Requests

Headers:
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 0
  X-RateLimit-Reset: 1717200060   ← 리셋 시각 (Unix timestamp)
  Retry-After: 30
```

## 적용 위치

- **[[API Gateway]]**: 외부 요청 전체에 적용 — 가장 일반적
- **서비스 단**: 특정 엔드포인트별 세밀한 제어
- **분산 환경**: Redis 공유로 다중 인스턴스 간 카운터 동기화 필수
