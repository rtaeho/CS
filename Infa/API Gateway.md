[[MSA]]에서 클라이언트의 모든 요청을 받아 적절한 서비스로 라우팅하는 단일 진입점으로, 인증·로드밸런싱·Rate Limiting 등 공통 기능을 중앙에서 처리합니다.

## 왜 필요한가

```
[API Gateway 없을 때]
클라이언트 ──→ 사용자 서비스 (8081)
            ──→ 주문 서비스  (8082)
            ──→ 결제 서비스  (8083)

→ 클라이언트가 각 서비스 URL을 알아야 함
→ 서비스마다 인증 로직 중복 구현
→ 서비스 추가 시 클라이언트 코드 변경 필요

[API Gateway 있을 때]
클라이언트 ──→ API Gateway (단일 URL)
                    │
           ┌────────┼────────┐
           ▼        ▼        ▼
        사용자    주문    결제 서비스
```

## 주요 기능

- **라우팅**: `/api/users/**` → 사용자 서비스, `/api/orders/**` → 주문 서비스
- **인증/인가**: [[JWT]] 검증을 Gateway에서 일괄 처리
- **Rate Limiting**: IP·사용자 단위 요청 수 제한, DDoS 방어
- **로드밸런싱**: 동일 서비스 여러 인스턴스에 분산
- **Circuit Breaker**: 서비스 장애 시 [[서킷 브레이커]] 동작
- **로깅/모니터링**: 모든 요청/응답 중앙 수집
- **SSL 종료**: HTTPS → HTTP 변환 (내부 서비스는 HTTP로 통신)

## Spring Cloud Gateway 예시

```java
// build.gradle
implementation 'org.springframework.cloud:spring-cloud-starter-gateway'
implementation 'org.springframework.cloud:spring-cloud-starter-circuitbreaker-reactor-resilience4j'
```

```yaml
# application.yml
spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: http://user-service:8081
          predicates:
            - Path=/api/users/**
          filters:
            - StripPrefix=1
            - name: CircuitBreaker
              args:
                name: userService
                fallbackUri: forward:/fallback

        - id: order-service
          uri: http://order-service:8082
          predicates:
            - Path=/api/orders/**
          filters:
            - StripPrefix=1
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 100
                redis-rate-limiter.burstCapacity: 200
```

```java
// JWT 검증 필터
@Component
public class JwtAuthFilter implements GlobalFilter, Ordered {

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String token = exchange.getRequest().getHeaders()
                .getFirst(HttpHeaders.AUTHORIZATION);

        if (token == null || !token.startsWith("Bearer ")) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        // JWT 검증 로직
        if (!jwtUtil.validate(token.substring(7))) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        return chain.filter(exchange);
    }

    @Override
    public int getOrder() { return -1; }
}
```

## 요청 처리 흐름

```
클라이언트 요청
      │
      ▼
Global Filter (JWT 검증, 로깅)
      │
      ▼
Route Matching (/api/orders/** → 주문 서비스)
      │
      ▼
Route Filter (Rate Limiting, Circuit Breaker)
      │
      ▼
대상 서비스로 프록시
      │
      ▼
응답 반환
```

## BFF 패턴 (Backend for Frontend)

클라이언트 종류별(모바일/웹/파트너사)로 API Gateway를 분리하는 패턴입니다.

```
모바일 앱   ──→ Mobile BFF   ──→ 내부 서비스
웹 브라우저 ──→ Web BFF      ──→ 내부 서비스
파트너사    ──→ Partner BFF  ──→ 내부 서비스
```

→ 각 클라이언트 특성에 맞게 응답 포맷·필드 최적화 가능
