Credentialed Request는 **쿠키, Authorization 헤더, TLS 인증서 등 사용자 인증 정보를 포함하여 Cross-Origin으로 보내는 요청**입니다.

## 왜 별도 개념이 필요한가

```
[기본 동작 — Cross-Origin 요청에 인증 정보 미포함]

fetch('https://api.example.com/profile', {
    method: 'GET'
});

→ 브라우저는 기본적으로 Cross-Origin 요청에 쿠키를 포함하지 않음
→ 서버에 세션 쿠키가 전달되지 않음
→ 서버: "로그인 안 된 사용자" → 401 Unauthorized

[이유]
→ 쿠키를 무조건 보내면 CSRF 공격에 취약
→ 보안을 위해 기본적으로 차단
→ 명시적으로 허용해야만 인증 정보 포함 가능
```

## Credentialed Request 활성화

클라이언트와 서버 **양쪽 모두** 설정이 필요합니다.

### 클라이언트 — credentials 설정

```javascript
// fetch API
fetch('https://api.example.com/profile', {
    method: 'GET',
    credentials: 'include'  // ← 핵심: 인증 정보 포함
});

// XMLHttpRequest
const xhr = new XMLHttpRequest();
xhr.open('GET', 'https://api.example.com/profile');
xhr.withCredentials = true;  // ← 핵심
xhr.send();

// axios
axios.get('https://api.example.com/profile', {
    withCredentials: true  // ← 핵심
});
```

### credentials 옵션 비교

|옵션|같은 출처|다른 출처|
|---|---|---|
|**omit**|쿠키 미포함|쿠키 미포함|
|**same-origin** (기본값)|쿠키 포함 ✅|쿠키 미포함|
|**include**|쿠키 포함 ✅|쿠키 포함 ✅|

```
same-origin (기본값):
https://example.com → https://example.com/api  → 쿠키 포함 ✅
https://example.com → https://api.example.com  → 쿠키 미포함 ❌

include:
https://example.com → https://example.com/api  → 쿠키 포함 ✅
https://example.com → https://api.example.com  → 쿠키 포함 ✅
```

### 서버 — CORS 응답 헤더 설정

```http
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://frontend.com
Access-Control-Allow-Credentials: true
```

```
[서버가 반드시 지켜야 하는 규칙]

1. Access-Control-Allow-Credentials: true 필수

2. Access-Control-Allow-Origin에 와일드카드(*) 사용 불가
   ❌ Access-Control-Allow-Origin: *
   ✅ Access-Control-Allow-Origin: https://frontend.com

3. Access-Control-Allow-Headers에 와일드카드(*) 사용 불가
   ❌ Access-Control-Allow-Headers: *
   ✅ Access-Control-Allow-Headers: Content-Type, Authorization

4. Access-Control-Allow-Methods에 와일드카드(*) 사용 불가
   ❌ Access-Control-Allow-Methods: *
   ✅ Access-Control-Allow-Methods: GET, POST, PUT, DELETE

→ 인증 정보를 포함하는 요청에는 정확한 출처/헤더/메서드를 명시해야 함
→ *은 "누구에게나 인증 정보를 보낸다"는 뜻이므로 보안상 차단
```

## 전체 통신 흐름

### 단순 요청 + Credential

```
브라우저                                    서버
   │                                        │
   │  GET /api/profile                      │
   │  Origin: https://frontend.com          │
   │  Cookie: sessionId=abc123  ← 쿠키 포함  │
   │ ───────────────────────────────────→    │
   │                                        │
   │  200 OK                                │
   │  Access-Control-Allow-Origin:          │
   │    https://frontend.com   ← * 불가      │
   │  Access-Control-Allow-Credentials:     │
   │    true                   ← 필수        │
   │  {"name": "홍길동", ...}               │
   │ ←───────────────────────────────────   │
```

### Preflight + Credential

```
브라우저                                    서버
   │                                        │
   │  ① OPTIONS /api/profile               │
   │  Origin: https://frontend.com          │
   │  Access-Control-Request-Method: PUT    │
   │  Access-Control-Request-Headers:       │
   │    Content-Type                        │
   │ ───────────────────────────────────→    │
   │                                        │
   │  ② 200 OK                             │
   │  Access-Control-Allow-Origin:          │
   │    https://frontend.com                │
   │  Access-Control-Allow-Methods:         │
   │    GET, POST, PUT, DELETE              │
   │  Access-Control-Allow-Credentials:     │
   │    true                                │
   │  Access-Control-Max-Age: 3600         │
   │ ←───────────────────────────────────   │
   │                                        │
   │  ③ PUT /api/profile                   │
   │  Origin: https://frontend.com          │
   │  Cookie: sessionId=abc123              │
   │  Content-Type: application/json        │
   │ ───────────────────────────────────→    │
   │                                        │
   │  ④ 200 OK                             │
   │  Access-Control-Allow-Origin:          │
   │    https://frontend.com                │
   │  Access-Control-Allow-Credentials:     │
   │    true                                │
   │ ←───────────────────────────────────   │
```

## Spring Boot 설정

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

        // ❌ 와일드카드 사용 불가 (Credentialed Request에서)
        // config.setAllowedOrigins(List.of("*"));

        // ✅ 정확한 출처 명시
        config.setAllowedOrigins(List.of("https://frontend.com"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
        config.setAllowedHeaders(List.of("Content-Type", "Authorization"));
        config.setAllowCredentials(true);  // ← 핵심
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);
        return source;
    }
}
```

### 다중 출처 허용 시

```java
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration config = new CorsConfiguration();

    // 여러 출처 허용
    config.setAllowedOrigins(List.of(
        "https://frontend.com",
        "https://admin.frontend.com",
        "http://localhost:3000"       // 개발 환경
    ));

    config.setAllowCredentials(true);

    // 또는 패턴 사용
    // config.setAllowedOriginPatterns(List.of("https://*.frontend.com"));
    // allowedOriginPatterns는 Credentials: true와 함께 사용 가능

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/api/**", config);
    return source;
}
```

## 흔한 에러와 해결

### 에러 1: 와일드카드 + Credentials

```
❌ 에러 메시지:
"Access to fetch at 'https://api.example.com' from origin
'https://frontend.com' has been blocked by CORS policy:
The value of 'Access-Control-Allow-Origin' must not be '*'
when the request's credentials mode is 'include'."
```

```java
// ❌ 원인
config.setAllowedOrigins(List.of("*"));
config.setAllowCredentials(true);

// ✅ 해결 — 정확한 출처 명시
config.setAllowedOrigins(List.of("https://frontend.com"));
config.setAllowCredentials(true);

// ✅ 또는 패턴 사용
config.setAllowedOriginPatterns(List.of("*"));  // 패턴은 Credentials와 사용 가능
config.setAllowCredentials(true);
```

### 에러 2: Credentials 헤더 누락

```
❌ 에러 메시지:
"The value of 'Access-Control-Allow-Credentials' header
must be 'true' when the request's credentials mode is 'include'."
```

```java
// ❌ 원인 — 서버에서 Allow-Credentials 미설정
config.setAllowCredentials(false);

// ✅ 해결
config.setAllowCredentials(true);
```

### 에러 3: 클라이언트 설정 누락

```javascript
// ❌ credentials 미설정 → 쿠키가 전송되지 않음
fetch('https://api.example.com/profile');

// ✅ credentials: 'include' 설정
fetch('https://api.example.com/profile', {
    credentials: 'include'
});
```

## CORS 요청 3가지 유형 전체 비교

| 항목                    | [[Simple Request]] | [[Preflight Request]] | Credentialed Request   |
| --------------------- | ------------------ | --------------------- | ---------------------- |
| **Preflight**         | 없음                 | OPTIONS 발생            | 조건에 따라 발생              |
| **인증 정보**             | 미포함                | 미포함                   | 쿠키/Authorization 포함    |
| **Allow-Origin: ***   | 허용                 | 허용                    | ❌ 불가                   |
| **Allow-Credentials** | 불필요                | 불필요                   | true 필수                |
| **클라이언트 설정**          | 없음                 | 없음                    | credentials: 'include' |
| **서버 설정**             | 최소                 | 메서드/헤더 허용             | 정확한 출처 + Credentials   |

```
[세 유형의 관계]

Credentialed Request는 독립 유형이 아니라
Simple / Preflight에 "인증 정보 포함"이 추가된 것

Simple + Credential:
→ GET (기본 헤더만) + credentials: 'include'
→ Preflight 없이 쿠키 포함 전송

Preflight + Credential:
→ POST (application/json) + credentials: 'include'
→ OPTIONS 확인 후 쿠키 포함 전송
```

```
[요청 분류 흐름]

                    ┌──────────────────────┐
                    │ credentials: include? │
                    └──────────┬───────────┘
                          │          │
                         No         Yes
                         │          │
                    ┌─────┴─────┐  Credentialed Request
                    │ 단순 요청?  │  (Allow-Origin: * 불가)
                    └─────┬─────┘
                     │         │
                    Yes        No
                     │         │
               Simple      Preflight
               Request     Request
```

## 면접 포인트

- Credentialed Request는 **쿠키나 Authorization 헤더 등 인증 정보를 Cross-Origin 요청에 포함하는 것**이며, 클라이언트(`credentials: 'include'`)와 서버(`Access-Control-Allow-Credentials: true`) 양쪽 모두 명시적으로 설정해야 합니다.
- 가장 중요한 제약은 **`Access-Control-Allow-Origin`에 와일드카드(`*`)를 사용할 수 없다**는 것이며, 정확한 출처를 명시해야 합니다. 이는 "모든 사이트에 인증 정보를 보낸다"는 보안 위험을 방지하기 위함입니다.
- Credentialed Request는 Simple/Preflight과 독립된 유형이 아니라, **기존 요청 유형에 인증 정보가 추가된 것**이며, 단순 요청이면 Preflight 없이 쿠키를 포함하여 전송하고, 비단순 요청이면 Preflight 후 쿠키를 포함하여 전송합니다.