Preflight Request는 **브라우저가 본 요청을 보내기 전에 OPTIONS 메서드로 서버에 "이 요청을 보내도 되는지" 사전에 확인하는 요청**입니다.

## 왜 필요한가

```
[Preflight 없이 바로 요청을 보내면?]

evil.com의 JavaScript:
fetch('https://bank.com/transfer', {
    method: 'DELETE',
    headers: { 'Authorization': 'Bearer stolen-token' }
});

→ 서버가 DELETE를 처리한 후 응답
→ 브라우저가 CORS 에러로 응답을 차단하더라도
→ 서버에서는 이미 삭제가 실행됨 ❌

→ "위험한 요청"은 보내기 전에 먼저 확인이 필요
→ 이것이 Preflight Request의 역할
```

```
[Preflight가 있으면]

1. 브라우저: OPTIONS로 "DELETE 보내도 돼?" 사전 확인
2. 서버: "안 돼" 또는 "돼" 응답
3-a. 허용: 브라우저가 본 요청(DELETE) 전송
3-b. 거부: 브라우저가 본 요청을 보내지 않음 ✅

→ 서버에서 실행되기 전에 차단 가능
```

## 전체 흐름

```
[Preflight + 본 요청 — 2번 통신]

브라우저                                  서버
   │                                      │
   │  ① OPTIONS /api/products             │
   │  Origin: https://frontend.com        │
   │  Access-Control-Request-Method: POST  │
   │  Access-Control-Request-Headers:      │
   │    Content-Type, Authorization        │
   │ ─────────────────────────────────→    │
   │                                      │
   │  ② 200 OK                           │
   │  Access-Control-Allow-Origin:        │
   │    https://frontend.com              │
   │  Access-Control-Allow-Methods:       │
   │    GET, POST, PUT, DELETE            │
   │  Access-Control-Allow-Headers:       │
   │    Content-Type, Authorization       │
   │  Access-Control-Max-Age: 3600       │
   │ ←─────────────────────────────────   │
   │                                      │
   │  ③ POST /api/products (본 요청)      │
   │  Origin: https://frontend.com        │
   │  Authorization: Bearer eyJhbG...     │
   │  Content-Type: application/json      │
   │ ─────────────────────────────────→    │
   │                                      │
   │  ④ 201 Created (본 응답)             │
   │ ←─────────────────────────────────   │
```

## 언제 Preflight가 발생하는가

브라우저는 요청을 **단순 요청([[Simple Request]])**과 **비단순 요청**으로 분류합니다. 비단순 요청일 때만 Preflight가 발생합니다.

### 단순 요청 — Preflight 없음

```
[모든 조건을 만족해야 단순 요청]

1. 메서드: GET, HEAD, POST 중 하나
2. 헤더: 아래 기본 헤더만 사용
   - Accept
   - Accept-Language
   - Content-Language
   - Content-Type (아래 3가지만 허용)
3. Content-Type: 아래 중 하나
   - application/x-www-form-urlencoded
   - multipart/form-data
   - text/plain
```

```javascript
// ✅ 단순 요청 — Preflight 없음
fetch('https://api.example.com/data', {
    method: 'GET'
});

// ✅ 단순 요청 — Preflight 없음
fetch('https://api.example.com/form', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: 'name=hong&age=25'
});
```

### 비단순 요청 — Preflight 발생

```javascript
// ❌ Content-Type: application/json → Preflight 발생
fetch('https://api.example.com/products', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'  // ← 단순 요청 조건 불충족
    },
    body: JSON.stringify({ name: '이어폰' })
});

// ❌ Authorization 헤더 → Preflight 발생
fetch('https://api.example.com/products', {
    method: 'GET',
    headers: {
        'Authorization': 'Bearer eyJhbG...'  // ← 커스텀 헤더
    }
});

// ❌ PUT, DELETE 메서드 → Preflight 발생
fetch('https://api.example.com/products/1', {
    method: 'DELETE'  // ← 단순 요청 메서드가 아님
});
```

### Preflight 발생 조건 정리

|조건|단순 요청 (Preflight 없음)|Preflight 발생|
|---|---|---|
|**메서드**|GET, HEAD, POST|PUT, DELETE, PATCH 등|
|**Content-Type**|form-urlencoded, multipart, text/plain|application/json 등|
|**커스텀 헤더**|없음|Authorization, X-Custom 등|

```
[실무에서는 거의 항상 Preflight 발생]

REST API:     Content-Type: application/json → Preflight ✅
JWT 인증:     Authorization: Bearer ... → Preflight ✅
PUT/DELETE:   RESTful 메서드 사용 → Preflight ✅

→ 단순 요청 조건이 매우 제한적이므로
→ 실무의 API 호출은 대부분 Preflight 발생
```

## Preflight 요청/응답 상세

### 요청 (브라우저가 자동 생성)

```http
OPTIONS /api/products HTTP/1.1
Host: api.example.com
Origin: https://frontend.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization
```

|헤더|설명|
|---|---|
|**Origin**|요청을 보내는 출처|
|**Access-Control-Request-Method**|본 요청에서 사용할 메서드|
|**Access-Control-Request-Headers**|본 요청에서 사용할 헤더|

### 응답 (서버가 반환)

```http
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://frontend.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 3600
```

|헤더|설명|
|---|---|
|**Access-Control-Allow-Origin**|허용하는 출처|
|**Access-Control-Allow-Methods**|허용하는 메서드|
|**Access-Control-Allow-Headers**|허용하는 헤더|
|**Access-Control-Allow-Credentials**|쿠키 포함 허용 여부|
|**Access-Control-Max-Age**|Preflight 결과 캐시 시간 (초)|

## Spring Boot에서의 CORS / Preflight 설정

### 전역 설정

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("https://frontend.com")
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                .allowedHeaders("Content-Type", "Authorization")
                .allowCredentials(true)
                .maxAge(3600);  // Preflight 캐시 1시간
    }
}
```

### Spring Security 설정

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable());

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("https://frontend.com"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
        config.setAllowedHeaders(List.of("Content-Type", "Authorization"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);
        return source;
    }
}
```

## Preflight 성능 최적화 — Max-Age 캐싱

```
[Max-Age 없이]
매 API 호출마다 2번 통신:
POST /api/products → OPTIONS + POST = 2번
PUT /api/products/1 → OPTIONS + PUT = 2번
DELETE /api/products/1 → OPTIONS + DELETE = 2번

→ API 10번 호출 → 실제 20번 통신 → 성능 저하

[Max-Age: 3600]
첫 번째 호출: OPTIONS + POST = 2번
이후 1시간 동안: POST만 = 1번 (캐시된 Preflight 결과 사용)

→ 같은 출처 + 같은 메서드 + 같은 헤더 조합에 대해
→ 브라우저가 Preflight 결과를 캐시
→ 캐시 유효 시간 동안 Preflight 생략
```

```
[캐시 동작]

첫 요청:
브라우저 ──OPTIONS──→ 서버 (Max-Age: 3600 응답)
브라우저 ──POST────→ 서버

2번째 요청 (1시간 이내):
브라우저 ──POST────→ 서버 (OPTIONS 생략 ✅)

1시간 후 요청:
브라우저 ──OPTIONS──→ 서버 (캐시 만료 → 다시 확인)
브라우저 ──POST────→ 서버
```

## Preflight가 발생하지 않는 경우들

```
1. 단순 요청 조건 충족
   → GET + 기본 헤더만 사용

2. 같은 출처 (Same-Origin)
   → https://example.com → https://example.com/api
   → CORS 자체가 적용되지 않음 → Preflight 불필요

3. Max-Age 캐시 유효 기간 내
   → 이전 Preflight 결과 재사용

4. 서버 간 통신
   → CORS는 브라우저 정책 → 서버 간 통신에는 적용 안 됨
   → Postman, curl 등에서도 Preflight 없음
```

## 전체 흐름 시각화

```
브라우저에서 API 호출 시:

                    ┌─────────────────────┐
                    │ 같은 출처(Origin)인가? │
                    └──────────┬──────────┘
                         │          │
                        Yes         No
                         │          │
                    Preflight    ┌──────────────────┐
                     불필요      │ 단순 요청 조건인가?  │
                         │      └────────┬─────────┘
                         │           │         │
                    본 요청 전송    Yes         No
                                    │         │
                               Preflight   ┌──────────────────┐
                                불필요      │ Max-Age 캐시 유효? │
                                    │      └────────┬─────────┘
                               본 요청 전송      │         │
                                              Yes         No
                                               │         │
                                          Preflight   OPTIONS 전송
                                           불필요      (Preflight)
                                               │         │
                                          본 요청 전송  허용 시 본 요청 전송
```

## 면접 포인트

- Preflight는 **브라우저가 위험할 수 있는 요청을 서버에 보내기 전에 OPTIONS 메서드로 허용 여부를 먼저 확인하는 메커니즘**이며, 서버에서 의도치 않은 동작이 실행되는 것을 사전에 방지합니다.
- 실무에서 REST API는 대부분 `Content-Type: application/json`이나 `Authorization` 헤더를 사용하므로 **거의 항상 Preflight가 발생**합니다. `Max-Age` 헤더로 Preflight 결과를 캐싱하여 성능 영향을 최소화하는 것이 중요합니다.
- Preflight는 **브라우저에서만 발생하는 동작**이며, Postman, curl, 서버 간 통신에서는 발생하지 않습니다. 이것이 "Postman에서는 되는데 브라우저에서는 안 되는" 상황의 원인입니다.