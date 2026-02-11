CORS(Cross-Origin Resource Sharing)란 **브라우저가 다른 출처(Origin)의 리소스에 접근하는 것을 제어하는 보안 메커니즘**으로, 서버가 허용한 출처에서만 리소스 접근을 가능하게 합니다.

## 왜 필요한가 — 동일 출처 정책(SOP)

브라우저는 기본적으로 **같은 출처끼리만 통신을 허용**하는 동일 출처 정책(Same-Origin Policy)을 적용합니다.

```
[Origin = Scheme + Host + Port]
https://example.com:443
└scheme┘└───host───┘└port┘
→ 이 세 가지 중 하나라도 다르면 Cross-Origin
```

|요청 출처|대상|동일 출처?|이유|
|---|---|---|---|
|`https://example.com`|`https://example.com/api`|✅|경로만 다름|
|`https://example.com`|`http://example.com`|❌|scheme 다름|
|`https://example.com`|`https://api.example.com`|❌|host 다름|
|`https://example.com`|`https://example.com:8080`|❌|port 다름|

## SOP가 없다면 어떤 일이 벌어지나

```
[SOP가 없는 세상 — CSRF 공격]

1. 사용자가 bank.com에 로그인 (쿠키에 세션 저장)
2. 사용자가 evil.com에 접속 (악성 사이트)
3. evil.com의 JavaScript:

   fetch("https://bank.com/api/transfer", {
       method: "POST",
       credentials: "include",  // bank.com 쿠키 자동 포함
       body: JSON.stringify({to: "해커", amount: 1000000})
   });

4. 브라우저가 bank.com 쿠키를 자동으로 포함하여 요청 전송
5. bank.com 서버: 정상 요청으로 판단 → 송금 실행 ❌

[SOP가 있는 세상]
3번에서 브라우저가 차단
→ evil.com(다른 출처)에서 bank.com으로의 요청 금지 ✅
```

## 그런데 왜 CORS가 필요한가

SOP는 보안에 필수적이지만, **현대 웹 아키텍처에서는 Cross-Origin 통신이 불가피**합니다.

```
[현대 웹 서비스 구조]
프론트엔드: https://frontend.example.com   (React, Vue 등)
API 서버:   https://api.example.com        (Spring Boot 등)

→ 출처가 다름 → SOP에 의해 차단됨
→ 하지만 통신이 필요함 → CORS로 허용
```

CORS는 SOP의 제한을 **서버가 명시적으로 허용한 범위 내에서 완화**하는 메커니즘입니다.

## CORS 동작 방식

### 1. 단순 요청 (Simple Request)

아래 조건을 **모두** 만족하면 프리플라이트 없이 바로 요청이 전송됩니다.

```
조건:
- 메서드: GET, HEAD, POST 중 하나
- 헤더: 기본 헤더만 사용 (Authorization 등 커스텀 헤더 없음)
- Content-Type: application/x-www-form-urlencoded, multipart/form-data, text/plain 중 하나
```

```
브라우저 → 서버: 본 요청 바로 전송
GET /api/posts HTTP/1.1
Origin: https://frontend.com

서버 → 브라우저:
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://frontend.com  ← 이 출처 허용

브라우저: Allow-Origin 확인 → 응답을 JavaScript에 전달 ✅
```

```
[서버가 허용하지 않은 경우]
HTTP/1.1 200 OK
(Access-Control-Allow-Origin 헤더 없음)

브라우저: 허용 안 됨 → JavaScript에 응답 전달 차단 ❌
→ 서버는 정상 처리했지만, 브라우저가 응답을 숨김
```

### 2. 프리플라이트 요청 (Preflight Request)

단순 요청 조건을 만족하지 않으면 **OPTIONS로 사전 확인 후 본 요청을 전송**합니다.

```
[1단계 — 프리플라이트 (브라우저가 자동 전송)]
OPTIONS /api/members HTTP/1.1
Origin: https://frontend.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization

[서버 응답 — 허용 범위 안내]
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://frontend.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 3600

[2단계 — 본 요청 (프리플라이트 통과 후)]
POST /api/members HTTP/1.1
Origin: https://frontend.com
Authorization: Bearer eyJhbG...
Content-Type: application/json

{"name": "홍길동"}

[서버 응답]
HTTP/1.1 201 Created
Access-Control-Allow-Origin: https://frontend.com
```

```
[실무에서 대부분 프리플라이트가 발생하는 이유]

REST API는 보통:
- Content-Type: application/json  ← 단순 요청 조건 불충족
- Authorization: Bearer ...       ← 커스텀 헤더

→ 거의 모든 API 요청에서 프리플라이트 발생
```

### 3. 인증 정보 포함 요청 (Credentialed Request)

쿠키나 인증 헤더를 Cross-Origin 요청에 포함해야 하는 경우입니다.

```javascript
// 클라이언트 — 쿠키 포함 요청
fetch("https://api.example.com/mypage", {
    credentials: "include"  // 쿠키 포함
});
```

```http
// 서버 응답 — 반드시 세 가지 조건 충족
Access-Control-Allow-Origin: https://frontend.com   // * 사용 불가
Access-Control-Allow-Credentials: true              // 필수
// Set-Cookie도 정상 동작
```

```
[주의]
credentials: "include" 사용 시
Access-Control-Allow-Origin: * → 불가 ❌
→ 반드시 정확한 출처를 명시해야 함
```

## CORS 응답 헤더 정리

|헤더|설명|예시|
|---|---|---|
|`Access-Control-Allow-Origin`|허용할 출처|`https://frontend.com` 또는 `*`|
|`Access-Control-Allow-Methods`|허용할 메서드|`GET, POST, PUT, DELETE`|
|`Access-Control-Allow-Headers`|허용할 헤더|`Content-Type, Authorization`|
|`Access-Control-Max-Age`|프리플라이트 캐시 시간(초)|`3600`|
|`Access-Control-Allow-Credentials`|인증 정보 포함 허용|`true`|
|`Access-Control-Expose-Headers`|JS에서 접근 가능한 응답 헤더|`X-Custom-Header`|

## Spring Boot CORS 설정

### 전역 설정

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
                .maxAge(3600);
    }
}
```

### Spring Security 설정

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

## 자주 발생하는 CORS 에러와 해결

|에러 메시지|원인|해결|
|---|---|---|
|`No 'Access-Control-Allow-Origin' header`|서버가 CORS 헤더를 반환하지 않음|서버에 CORS 설정 추가|
|`Origin is not allowed`|요청 출처가 Allow-Origin에 없음|해당 출처를 허용 목록에 추가|
|`credentials flag is true but Allow-Origin is *`|인증 포함 요청인데 와일드카드 사용|`*` 대신 정확한 출처 명시|
|`Method is not allowed`|Allow-Methods에 해당 메서드 없음|필요한 메서드를 허용 목록에 추가|

## 핵심 정리

```
SOP: 브라우저의 기본 보안 정책 → 다른 출처 요청 차단
CORS: SOP를 완화하는 메커니즘 → 서버가 허용한 출처만 통과

주체: 서버가 아닌 "브라우저"가 차단
→ Postman, 서버 간 통신에서는 CORS 제약 없음
→ 서버는 요청을 정상 처리했지만, 브라우저가 응답을 JavaScript에 전달하지 않는 것
```

## 면접 포인트

- CORS는 **브라우저의 보안 정책**이므로, 서버가 요청을 거부하는 것이 아니라 **브라우저가 응답을 차단**하는 것입니다. 같은 요청을 Postman이나 서버에서 보내면 정상 동작합니다.
- SOP가 없다면 **악성 사이트에서 사용자의 인증 정보를 이용해 다른 사이트에 요청을 보내는 공격**이 가능해지므로, SOP는 웹 보안의 근간입니다.
- 실무에서 `application/json`과 `Authorization` 헤더를 사용하면 거의 모든 요청에서 프리플라이트가 발생하므로, `Max-Age`로 캐싱하여 **불필요한 OPTIONS 요청을 줄이는 것**이 성능 최적화의 핵심입니다.