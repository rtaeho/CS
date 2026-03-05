401은 **[[인증]](Authentication) 실패**, 403은 **[[인가]](Authorization) 실패**를 의미하며, "너 누구야?"와 "너 누군지는 알지만 권한이 없어"의 차이입니다.

## 인증 vs 인가

```
인증 (Authentication): 신원 확인 → "이 사람이 누구인가?"
인가 (Authorization):  권한 확인 → "이 사람이 이 행동을 할 수 있는가?"

[비유]
건물 출입증이 없음      → 401 (인증 실패: 너 누구야?)
출입증은 있지만 3층 출입 불가 → 403 (인가 실패: 너 여기 못 들어가)
```

## 동작 차이

```
[401 Unauthorized]
클라이언트: GET /mypage (토큰/세션 없음)
서버:       "인증 정보가 없거나 유효하지 않습니다" → 401
           WWW-Authenticate 헤더로 인증 방법 안내
클라이언트: 로그인 후 재요청하면 성공 가능 ✅

[403 Forbidden]
클라이언트: GET /admin (일반 사용자 토큰으로 요청)
서버:       "인증은 확인했지만 접근 권한이 없습니다" → 403
클라이언트: 로그인을 다시 해도 소용없음 ❌ → 권한 자체가 없기 때문
```

|항목|401 Unauthorized|403 Forbidden|
|---|---|---|
|**의미**|인증 실패|인가 실패|
|**서버가 사용자를 아는가**|모름|알고 있음|
|**재시도 시 해결 가능**|로그인하면 해결 가능|권한이 부여되지 않는 한 불가|
|**응답 헤더**|`WWW-Authenticate` 포함 권장|별도 헤더 없음|
|**대표 상황**|토큰 없음, 토큰 만료, 잘못된 자격 증명|일반 유저가 관리자 API 접근|

## Spring Security 동작 흐름

```
요청 진입
  │
  ▼
인증 필터 (AuthenticationFilter)
  │
  ├─ 인증 정보 없음/유효하지 않음 → AuthenticationEntryPoint → 401
  │
  ▼
인가 필터 (AuthorizationFilter)
  │
  ├─ 권한 부족 → AccessDeniedHandler → 403
  │
  ▼
컨트롤러 도달 (정상 처리)
```

```java
@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .requestMatchers("/mypage/**").authenticated()
                .anyRequest().permitAll()
            )
            // 401 처리 — 인증 실패
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setStatus(401);
                    response.getWriter().write("인증이 필요합니다");
                })
                // 403 처리 — 인가 실패
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    response.setStatus(403);
                    response.getWriter().write("접근 권한이 없습니다");
                })
            );
        return http.build();
    }
}
```

## 실무에서 흔히 혼동하는 상황

|상황|올바른 코드|이유|
|---|---|---|
|토큰 없이 API 요청|**401**|인증 자체가 안 됨|
|만료된 토큰으로 요청|**401**|유효한 인증 정보가 아님|
|일반 유저가 관리자 API 요청|**403**|인증은 됐지만 권한 부족|
|자기 것이 아닌 타인의 리소스 접근|**403**|인증은 됐지만 해당 리소스에 권한 없음|
|비활성화된 계정으로 요청|**403**|인증은 됐지만 계정이 차단 상태|

### 타인의 리소스 접근 예시

```java
@GetMapping("/orders/{orderId}")
public ResponseEntity<Order> getOrder(@PathVariable Long orderId,
                                       @AuthenticationPrincipal UserDetails user) {
    Order order = orderService.findById(orderId);

    // 인증은 됐지만 본인 주문이 아닌 경우 → 403
    if (!order.getMemberId().equals(user.getId())) {
        throw new AccessDeniedException("본인의 주문만 조회할 수 있습니다");
    }

    return ResponseEntity.ok(order);
}
```

## 보안 관점에서의 고민: 403 대신 404를 쓰는 경우

```
GET /admin/users → 403 Forbidden
→ 공격자: "이 URL이 존재하는구나, 관리자 페이지가 있구나" ← 정보 노출

GET /admin/users → 404 Not Found
→ 공격자: "이 URL은 없나 보다" ← 존재 자체를 숨김
```

보안이 중요한 서비스에서는 권한 없는 리소스에 대해 **의도적으로 404를 반환**하여 리소스 존재 여부를 숨기기도 합니다. GitHub가 대표적인 사례로, 접근 권한이 없는 Private 저장소에 접근하면 403이 아닌 404를 반환합니다.

## 면접 포인트

- 401과 403은 **인증과 인가**라는 서로 다른 보안 개념에 대응하며, 이 둘을 명확히 구분할 수 있어야 합니다.
- 401의 이름이 "Unauthorized"이지만 실제 의미는 **"Unauthenticated"에 가깝다**는 점은 HTTP 스펙의 역사적 네이밍 문제로 자주 언급됩니다.
- 보안이 중요한 환경에서는 403 대신 404를 반환하여 **리소스 존재 여부를 숨기는 전략**도 있다는 점까지 답하면 깊이 있는 답변이 됩니다.