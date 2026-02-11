[[HTTP]] 응답 코드는 클라이언트의 요청에 대해 **서버가 처리 결과를 3자리 숫자로 표현하여 반환하는 상태 코드**입니다.

## 응답 코드 분류 체계

첫 번째 자리 숫자가 응답의 종류를 나타냅니다.

|범위|분류|의미|
|---|---|---|
|**1xx**|Informational|요청을 받았으며 처리 중|
|**2xx**|Success|요청 성공|
|**3xx**|Redirection|요청 완료를 위해 추가 동작 필요|
|**4xx**|Client Error|클라이언트 측 오류|
|**5xx**|Server Error|서버 측 오류|

## 2xx — 성공

|코드|이름|설명|사용 예시|
|---|---|---|---|
|**200**|OK|요청 성공|GET 조회 성공|
|**201**|Created|리소스 생성 성공|POST로 새 리소스 생성|
|**204**|No Content|성공했으나 응답 본문 없음|DELETE 처리 후 반환할 데이터 없음|

```java
// Spring 예시
@GetMapping("/members/{id}")
public ResponseEntity<Member> getMember(@PathVariable Long id) {
    Member member = memberService.findById(id);
    return ResponseEntity.ok(member);  // 200 OK
}

@PostMapping("/members")
public ResponseEntity<Member> createMember(@RequestBody MemberRequest request) {
    Member member = memberService.create(request);
    return ResponseEntity.status(HttpStatus.CREATED).body(member);  // 201 Created
}

@DeleteMapping("/members/{id}")
public ResponseEntity<Void> deleteMember(@PathVariable Long id) {
    memberService.delete(id);
    return ResponseEntity.noContent().build();  // 204 No Content
}
```

## 3xx — 리다이렉션

|코드|이름|설명|특징|
|---|---|---|---|
|**301**|Moved Permanently|영구 이동|브라우저가 URL을 캐싱, 이후 자동으로 새 URL 접근|
|**302**|Found|임시 이동|요청마다 원래 URL에 먼저 접근|
|**304**|Not Modified|캐시 사용|리소스 변경 없음 → 클라이언트 캐시 데이터 사용|

```
[301 vs 302]

301 영구 이동:
GET /old-page → 301 Location: /new-page
→ 브라우저가 기억 → 이후 /old-page 요청 시 서버에 안 가고 바로 /new-page로

302 임시 이동:
GET /event → 302 Location: /event-2025
→ 브라우저가 기억 안 함 → 매번 /event에 먼저 요청
→ 나중에 /event-2026으로 바꿀 수 있음
```

```
[304 동작 흐름]
1. 클라이언트 → 서버: GET /logo.png (If-Modified-Since: 2025-01-01)
2. 서버: 리소스 변경 안 됨 → 304 Not Modified (본문 없이 응답)
3. 클라이언트: 기존 캐시된 logo.png 사용 → 네트워크 비용 절약
```

## 4xx — 클라이언트 오류

|코드|이름|설명|사용 예시|
|---|---|---|---|
|**400**|Bad Request|잘못된 요청 (문법 오류, 유효성 실패)|필수 파라미터 누락, 잘못된 데이터 형식|
|**401**|Unauthorized|인증 필요|로그인하지 않은 상태에서 접근|
|**403**|Forbidden|권한 없음|인증은 됐으나 접근 권한이 없는 리소스|
|**404**|Not Found|리소스 없음|존재하지 않는 URL 요청|
|**405**|Method Not Allowed|허용되지 않은 HTTP 메서드|GET만 가능한 URL에 DELETE 요청|
|**409**|Conflict|리소스 충돌|이미 존재하는 아이디로 회원가입|
|**429**|Too Many Requests|요청 횟수 초과|API Rate Limit 초과|

### 401 vs 403 차이

```
[401 Unauthorized — 인증 실패]
"너 누구야?" → 로그인 자체가 안 된 상태
GET /mypage → 토큰/세션 없음 → 401

[403 Forbidden — 인가 실패]
"너 누군지는 알지만 권한이 없어" → 로그인은 됐으나 접근 불가
GET /admin → 일반 사용자가 관리자 페이지 접근 → 403
```

```java
// Spring Security 예시
@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/admin/**").hasRole("ADMIN")  // 권한 없으면 403
                .requestMatchers("/mypage/**").authenticated()   // 미인증 시 401
                .anyRequest().permitAll()
            );
        return http.build();
    }
}
```

## 5xx — 서버 오류

|코드|이름|설명|사용 예시|
|---|---|---|---|
|**500**|Internal Server Error|서버 내부 오류|예외 미처리, NullPointerException 등|
|**502**|Bad Gateway|게이트웨이/프록시가 백엔드에서 잘못된 응답 수신|Nginx → WAS 통신 실패|
|**503**|Service Unavailable|서버 일시적 과부하 또는 점검 중|배포 중, 서버 과부하|
|**504**|Gateway Timeout|게이트웨이/프록시가 백엔드 응답 시간 초과|WAS 응답이 너무 느림|

```
[502 vs 504 — 로드밸런서/Nginx 관점]

502 Bad Gateway:
Nginx → WAS: 요청 전달 → WAS가 비정상 응답 또는 연결 거부
→ "백엔드가 이상한 응답을 줬어"

504 Gateway Timeout:
Nginx → WAS: 요청 전달 → WAS가 응답을 안 함 (시간 초과)
→ "백엔드가 너무 오래 걸려"
```

## 실무에서 자주 쓰는 응답 코드 요약

```
성공:     200 (조회) / 201 (생성) / 204 (삭제)
리다이렉트: 301 (영구) / 302 (임시)
클라이언트: 400 (잘못된 요청) / 401 (미인증) / 403 (미인가) / 404 (없음)
서버:      500 (서버 오류) / 502 (게이트웨이) / 503 (과부하)
```

## 면접 포인트

- 401과 403의 차이를 **인증(Authentication)과 인가(Authorization)** 개념으로 구분하여 설명할 수 있어야 합니다.
- 5xx 에러는 **클라이언트의 잘못이 아닌 서버 측 문제**이므로, API 설계 시 클라이언트 입력 오류를 5xx로 반환하지 않도록 주의해야 합니다.
- REST API 설계 시 적절한 응답 코드를 반환하는 것은 **클라이언트가 에러 원인을 빠르게 파악하고 대응**할 수 있도록 하는 핵심 요소입니다.