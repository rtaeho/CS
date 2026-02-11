OPTIONS는 특정 리소스에 대해 **서버가 허용하는 통신 옵션(메서드, 헤더 등)을 확인하기 위한 HTTP 메서드**이며, 실무에서는 주로 CORS 프리플라이트 요청에서 사용됩니다.

## 기본 동작

```http
// 클라이언트: 이 리소스에 어떤 메서드를 쓸 수 있나?
OPTIONS /members HTTP/1.1

// 서버: 이 메서드들 사용 가능해
HTTP/1.1 200 OK
Allow: GET, POST, PUT, DELETE, OPTIONS
```

서버의 리소스를 변경하지 않으므로 **안전(Safe)하고 멱등(Idempotent)**합니다.

## OPTIONS가 실무에서 중요한 이유 — CORS

### [[CORS]]란?

```
[Same-Origin — 같은 출처]
프론트엔드: https://example.com
API 서버:   https://example.com/api
→ 같은 출처 → 제한 없이 통신 가능 ✅

[Cross-Origin — 다른 출처]
프론트엔드: https://frontend.com
API 서버:   https://api.backend.com
→ 다른 출처 → 브라우저가 기본적으로 차단 ❌
```

브라우저는 보안을 위해 **다른 출처(Origin)로의 요청을 기본적으로 차단**합니다. 이를 허용하기 위한 메커니즘이 **CORS(Cross-Origin Resource Sharing)**이며, 그 핵심에 OPTIONS 프리플라이트 요청이 있습니다.

### Origin이란?

```
https://example.com:443/path
└─scheme─┘└──host──┘└port┘

Origin = Scheme + Host + Port
→ 이 세 가지 중 하나라도 다르면 Cross-Origin
```

|요청 출처|대상|같은 출처?|
|---|---|---|
|`https://example.com`|`https://example.com/api`|✅ 같음|
|`https://example.com`|`http://example.com`|❌ scheme 다름|
|`https://example.com`|`https://api.example.com`|❌ host 다름|
|`https://example.com`|`https://example.com:8080`|❌ port 다름|

## 프리플라이트 요청 (Preflight Request)

브라우저가 본 요청을 보내기 전에 **OPTIONS로 먼저 서버에 허락을 구하는 사전 요청**입니다.

### 전체 흐름

```
[1단계 — 프리플라이트 (OPTIONS)]
브라우저 → 서버: "이런 요청 보내도 돼?"
OPTIONS /members HTTP/1.1
Origin: https://frontend.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization

서버 → 브라우저: "이 조건이면 허용할게"
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://frontend.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 3600

[2단계 — 본 요청 (POST)]
브라우저: 프리플라이트 통과 확인 → 본 요청 전송
POST /members HTTP/1.1
Origin: https://frontend.com
Authorization: Bearer eyJhbG...
Content-Type: application/json

{"name": "홍길동"}

서버 → 브라우저:
HTTP/1.1 201 Created
Access-Control-Allow-Origin: https://frontend.com
```

### 프리플라이트 요청/응답 헤더 정리

**요청 헤더 (브라우저 → 서버)**

|헤더|설명|
|---|---|
|`Origin`|요청을 보내는 출처|
|`Access-Control-Request-Method`|본 요청에서 사용할 메서드|
|`Access-Control-Request-Headers`|본 요청에서 사용할 커스텀 헤더|

**응답 헤더 (서버 → 브라우저)**

|헤더|설명|
|---|---|
|`Access-Control-Allow-Origin`|허용하는 출처 (`*` 또는 특정 도메인)|
|`Access-Control-Allow-Methods`|허용하는 메서드 목록|
|`Access-Control-Allow-Headers`|허용하는 헤더 목록|
|`Access-Control-Max-Age`|프리플라이트 결과 캐시 시간 (초)|
|`Access-Control-Allow-Credentials`|쿠키/인증 정보 포함 허용 여부|

## 프리플라이트가 발생하는 조건

모든 Cross-Origin 요청에 프리플라이트가 발생하는 것은 아닙니다.

### 단순 요청 (Simple Request) — 프리플라이트 없음

아래 조건을 **모두** 만족하면 프리플라이트 없이 바로 본 요청을 보냅니다.

```
1. 메서드: GET, HEAD, POST 중 하나
2. 헤더: Accept, Content-Type 등 기본 헤더만 사용
3. Content-Type: 아래 세 가지 중 하나
   - application/x-www-form-urlencoded
   - multipart/form-data
   - text/plain
```

### 프리플라이트 발생 — 하나라도 해당되면

```
- PUT, PATCH, DELETE 메서드 사용
- Authorization 같은 커스텀 헤더 포함
- Content-Type: application/json 사용  ← 실무에서 거의 항상 해당
```

```
[실무에서 대부분 프리플라이트가 발생하는 이유]
REST API는 보통 Content-Type: application/json을 사용하고
Authorization 헤더로 토큰을 전달하므로
→ 단순 요청 조건을 만족하지 않음
→ 거의 모든 API 요청에 프리플라이트 발생
```

## Spring Boot CORS 설정

### 방법 1: 전역 설정

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("https://frontend.com")
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);  // 프리플라이트 캐시 1시간
    }
}
```

### 방법 2: Spring Security 설정

```java
@Configuration
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
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);
        return source;
    }
}
```

### 방법 3: 컨트롤러 레벨

```java
@CrossOrigin(origins = "https://frontend.com")
@RestController
@RequestMapping("/api/members")
public class MemberController {
    // ...
}
```

## 프리플라이트 성능 최적화

매 요청마다 OPTIONS가 선행되면 **요청 수가 2배**가 되므로 성능에 영향을 줄 수 있습니다.

```
요청 1회 → OPTIONS + 본 요청 = 실제 2회 네트워크 통신

[해결: Access-Control-Max-Age]
Access-Control-Max-Age: 3600 (1시간)
→ 브라우저가 프리플라이트 결과를 1시간 동안 캐시
→ 캐시 기간 내에는 프리플라이트 생략하고 바로 본 요청 전송
```

## 면접 포인트

- OPTIONS 자체보다는 **CORS와 프리플라이트 요청의 동작 원리**를 함께 설명할 수 있어야 합니다.
- CORS는 **브라우저가 적용하는 보안 정책**이므로, Postman이나 서버 간 통신에서는 CORS 제약이 없습니다. 즉 서버가 차단하는 것이 아니라 브라우저가 차단하는 것입니다.
- 실무에서 `Content-Type: application/json`과 `Authorization` 헤더를 사용하는 경우가 대부분이므로, 거의 모든 API 요청에서 프리플라이트가 발생하며, `Max-Age` 설정으로 성능을 최적화해야 합니다.