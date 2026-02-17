CSRF(Cross-Site Request Forgery)는 **사용자가 의도하지 않은 요청을 인증된 상태에서 악성 사이트가 대신 보내는 공격**입니다.

## 공격 원리

```
[정상적인 흐름]
1. 사용자가 bank.com에 로그인 → 세션 쿠키 발급
2. 사용자가 bank.com에서 송금 요청
3. 브라우저가 쿠키를 자동으로 포함하여 전송
4. 서버: 쿠키 확인 → 인증된 사용자 → 송금 처리

[CSRF 공격]
1. 사용자가 bank.com에 로그인 → 세션 쿠키 보유 중
2. 사용자가 악성 사이트(evil.com) 방문
3. evil.com이 bank.com으로 송금 요청을 몰래 전송
4. 브라우저가 bank.com의 쿠키를 자동으로 포함 ← 핵심!
5. 서버: 쿠키 확인 → 인증된 사용자 → 송금 처리 ❌

→ 사용자는 요청을 보낸 적이 없지만
→ 브라우저가 쿠키를 자동 전송하므로 서버는 정상 요청으로 인식
```

## 구체적인 공격 예시

### 1. 이미지 태그를 이용한 GET 공격

```html
<!-- evil.com의 페이지 -->
<!-- 사용자가 이 페이지를 열기만 하면 공격 실행 -->
<img src="https://bank.com/transfer?to=hacker&amount=1000000" />

<!-- 브라우저: bank.com에 GET 요청 전송 -->
<!-- 쿠키가 자동으로 포함됨 -->
<!-- 서버: 정상 요청으로 처리 ❌ -->
```

### 2. 폼을 이용한 POST 공격

```html
<!-- evil.com의 페이지 -->
<body onload="document.forms[0].submit()">
    <!-- 페이지 로드 시 자동 제출 -->
    <form action="https://bank.com/transfer" method="POST">
        <input type="hidden" name="to" value="hacker" />
        <input type="hidden" name="amount" value="1000000" />
    </form>
</body>

<!-- 사용자가 evil.com을 방문하는 순간 -->
<!-- bank.com으로 POST 요청이 자동 전송 -->
<!-- bank.com의 쿠키가 자동으로 포함 -->
```

### 3. 링크를 이용한 공격

```html
<!-- 이메일이나 게시글에 포함 -->
<a href="https://bank.com/transfer?to=hacker&amount=1000000">
    무료 쿠폰 받기! 클릭하세요!
</a>

<!-- 사용자가 클릭하면 공격 실행 -->
```

## CSRF가 가능한 이유

```
[브라우저의 쿠키 자동 전송 정책]

브라우저는 해당 도메인의 쿠키를 요청에 자동으로 포함

evil.com에서 bank.com으로 요청 시:
→ 브라우저: "bank.com 요청이니까 bank.com 쿠키를 붙여야지"
→ 세션 쿠키가 자동으로 포함됨
→ 서버 입장에서는 정상 로그인 사용자의 요청으로 보임

요청 출처(evil.com)와 관계없이
요청 대상(bank.com)의 쿠키가 포함되는 것이 핵심 문제
```

```
[CSRF vs XSS 차이]

CSRF:
→ 쿠키를 "읽지" 않음
→ 브라우저가 쿠키를 "자동 전송"하는 것을 악용
→ 사용자의 권한으로 원치 않는 "행동"을 실행

XSS:
→ 악성 스크립트를 페이지에 삽입
→ 쿠키를 "읽어서" 탈취 가능 (HttpOnly가 아닌 경우)
→ 사용자의 정보를 "탈취"
```

|항목|CSRF|XSS|
|---|---|---|
|**목적**|사용자 권한으로 행동 실행|데이터 탈취, 스크립트 실행|
|**쿠키 접근**|읽지 않음 (자동 전송 이용)|읽을 수 있음|
|**공격 위치**|외부 사이트에서 요청|대상 사이트 내부에 스크립트 삽입|
|**HttpOnly 효과**|방어 불가 ❌|쿠키 탈취 방지 ✅|

## 방어 방법

### 1. CSRF Token

가장 대표적인 방어 방법입니다. 서버가 **예측 불가능한 토큰을 발급하여 폼에 포함**하고, 요청 시 검증합니다.

```
[동작 원리]

1. 서버: 랜덤 CSRF Token 생성 → 세션에 저장 + 폼에 포함
2. 클라이언트: 폼 제출 시 CSRF Token 함께 전송
3. 서버: 세션의 토큰과 요청의 토큰 비교 → 일치하면 처리

evil.com은 이 토큰 값을 알 수 없으므로 공격 불가
→ 같은 출처(same-origin)가 아니면 토큰을 읽을 수 없음 (SOP)
```

```html
<!-- 서버가 렌더링한 폼 -->
<form action="/transfer" method="POST">
    <input type="hidden" name="_csrf" value="a8f3b2c9d1e4f567" />
    <input type="text" name="to" />
    <input type="number" name="amount" />
    <button type="submit">송금</button>
</form>

<!-- evil.com에서는 이 토큰(a8f3b2c9d1e4f567)을 알 수 없음 -->
<!-- 토큰 없이 요청하면 서버가 거부 -->
```

```java
// Spring Security — CSRF 토큰 자동 적용 (기본 활성화)
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf
                .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
            );
        // Spring Security는 기본적으로 CSRF 방어가 활성화됨
        // 모든 POST, PUT, DELETE 요청에 CSRF 토큰 검증

        return http.build();
    }
}
```

```html
<!-- Thymeleaf — 자동으로 CSRF 토큰 삽입 -->
<form th:action="@{/transfer}" method="post">
    <!-- _csrf 히든 필드가 자동 추가됨 -->
    <input type="text" name="to" />
    <button type="submit">송금</button>
</form>
```

### 2. SameSite 쿠키

```
브라우저가 다른 사이트에서의 요청에 쿠키를 포함하지 않도록 설정

SameSite=Strict: 다른 사이트에서의 요청에 쿠키 전송 안 함
SameSite=Lax:    GET 요청에만 쿠키 전송 (기본값)
SameSite=None:   모든 요청에 쿠키 전송 (Secure 필수)
```

```
[SameSite=Lax (기본값)]

같은 사이트 요청:
bank.com → bank.com/transfer (POST) → 쿠키 포함 ✅

다른 사이트 요청:
evil.com → bank.com/transfer (POST) → 쿠키 미포함 ✅ CSRF 차단
evil.com → bank.com/products (GET)  → 쿠키 포함 (링크 클릭 등)
```

```java
// Spring Boot — SameSite 쿠키 설정
@Bean
public CookieSerializer cookieSerializer() {
    DefaultCookieSerializer serializer = new DefaultCookieSerializer();
    serializer.setSameSite("Lax");    // Strict, Lax, None
    serializer.setUseSecureCookie(true);
    return serializer;
}
```

|SameSite|같은 사이트|다른 사이트 GET|다른 사이트 POST|
|---|---|---|---|
|**Strict**|✅|❌|❌|
|**Lax**|✅|✅|❌|
|**None**|✅|✅|✅|

### 3. Referer / Origin 헤더 검증

```
[요청 시 브라우저가 자동으로 포함하는 헤더]

같은 사이트에서 요청:
Origin: https://bank.com
Referer: https://bank.com/transfer-form

evil.com에서 요청:
Origin: https://evil.com          ← 서버가 이것을 확인
Referer: https://evil.com/attack  ← 출처가 다름 → 거부
```

```java
// Origin 헤더 검증
@Component
public class CsrfOriginFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                     HttpServletResponse response,
                                     FilterChain chain) throws ServletException, IOException {

        if ("POST".equals(request.getMethod())) {
            String origin = request.getHeader("Origin");

            if (origin != null && !origin.equals("https://bank.com")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Invalid origin");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
```

### 4. JWT (Bearer Token) 사용

```
[쿠키 대신 Authorization 헤더로 인증]

쿠키 기반:
→ 브라우저가 자동으로 전송 → CSRF 공격에 취약

JWT (Bearer Token):
→ JavaScript가 수동으로 헤더에 설정 → 자동 전송 안 됨
→ evil.com의 JS는 토큰에 접근 불가 (SOP) → CSRF에 구조적으로 안전
```

```javascript
// JWT 방식 — Authorization 헤더에 수동 설정
fetch('https://bank.com/transfer', {
    method: 'POST',
    headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1...',  // 수동 설정
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({ to: 'friend', amount: 50000 })
});

// evil.com에서는:
// → bank.com의 localStorage에 접근 불가 (SOP)
// → 토큰을 알 수 없으므로 Authorization 헤더를 설정할 수 없음
// → CSRF 공격 불가 ✅
```

## 방어 방법 비교

|방어 방법|원리|적합한 환경|
|---|---|---|
|**CSRF Token**|예측 불가능한 토큰 검증|SSR (Thymeleaf 등) ✅|
|**SameSite 쿠키**|다른 사이트에서 쿠키 미전송|모든 환경 ✅|
|**Referer/Origin 검증**|요청 출처 확인|보조적 방어|
|**JWT (Bearer Token)**|쿠키 미사용, 수동 헤더|CSR (SPA) ✅|

## Spring Security의 CSRF 처리

```java
// SSR 환경 — CSRF 활성화 (기본값)
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
        .csrf(csrf -> csrf
            .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
        );
    return http.build();
}

// CSR(SPA) + JWT 환경 — CSRF 비활성화
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
        .csrf(csrf -> csrf.disable())  // JWT 사용 시 CSRF 불필요
        .sessionManagement(session ->
            session.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
    return http.build();
}
```

```
[왜 JWT에서는 CSRF를 비활성화하는가?]

CSRF의 전제 조건: 브라우저가 쿠키를 자동 전송
JWT 환경: 쿠키를 사용하지 않고 Authorization 헤더에 수동 설정
→ 자동 전송이 없으므로 CSRF 공격 자체가 성립하지 않음
→ CSRF 방어가 불필요
```

## 공격 흐름 전체 시각화

```
[CSRF 공격 성공 시]
사용자 ──→ bank.com 로그인 ──→ 세션 쿠키 발급
  │
  └──→ evil.com 방문
         │
         └──→ evil.com이 bank.com으로 요청 생성
                │
                └──→ 브라우저: bank.com 쿠키 자동 포함
                       │
                       └──→ bank.com 서버: 정상 요청으로 처리 ❌

[CSRF Token으로 방어 시]
사용자 ──→ bank.com 로그인 ──→ 세션 쿠키 + CSRF 토큰 발급
  │
  └──→ evil.com 방문
         │
         └──→ evil.com이 bank.com으로 요청 생성
                │
                └──→ 브라우저: bank.com 쿠키 포함 + CSRF 토큰 없음
                       │
                       └──→ bank.com 서버: 토큰 불일치 → 거부 ✅
```

## 면접 포인트

- CSRF의 핵심은 **브라우저가 쿠키를 자동으로 전송하는 특성**을 악용하는 것이며, 공격자는 쿠키를 읽지 않고도 사용자의 인증된 상태를 이용하여 원치 않는 행동을 실행시킬 수 있습니다.
- 가장 대표적인 방어는 **CSRF Token**으로, 서버가 발급한 예측 불가능한 토큰을 요청에 포함시켜 검증합니다. 공격자는 SOP(Same-Origin Policy)에 의해 이 토큰을 알 수 없으므로 공격이 차단됩니다.
- JWT(Bearer Token) 방식은 쿠키가 아닌 **Authorization 헤더에 수동으로 토큰을 설정**하므로 자동 전송이 발생하지 않아 CSRF에 구조적으로 안전합니다. 그래서 SPA + JWT 환경에서는 Spring Security의 CSRF를 비활성화하는 것이 일반적입니다.