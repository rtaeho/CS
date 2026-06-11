---
title: "Filter"
tags: [Spring, MVC, 필터]
status: published
---

서블릿 컨테이너(Tomcat) 레벨에서 HTTP 요청/응답을 가로채 공통 처리를 수행하는 컴포넌트로, Spring Context 밖에서 동작합니다.

## 동작 위치

```
클라이언트 요청
    ↓
[ Filter 1 ]  ← 여기 (서블릿 컨테이너)
[ Filter 2 ]
    ↓
DispatcherServlet
    ↓
Controller
    ↓
[ Filter 2 ]
[ Filter 1 ]
    ↓
클라이언트 응답
```

## 구현

```java
@Component
public class LoggingFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        System.out.println("요청: " + req.getRequestURI());

        chain.doFilter(request, response);  // 다음 필터 또는 서블릿으로 전달

        System.out.println("응답 완료");
    }
}
```

`chain.doFilter()` 호출 전 → 요청 처리, 호출 후 → 응답 처리

## 핵심 특징

- `HttpServletRequest` / `HttpServletResponse` 직접 조작 가능 (바이트 수준 변형)
- Spring Bean 주입 가능 (`@Component`로 등록 시)
- 예외 발생 시 `@ControllerAdvice`로 잡히지 않음 → 별도 처리 필요
- `@Component`만으로 자동 등록, 순서 지정은 `@Order` 또는 `FilterRegistrationBean` 사용

## 주요 사용 사례

- **Spring Security** — 인증·인가 필터 체인으로 동작
- **CORS 처리** — 모든 요청에 CORS 헤더 추가
- **요청/응답 로깅** — URI, 파라미터, 응답 코드 기록
- **XSS 방어** — 입력값 이스케이프
- **인코딩 설정** — `CharacterEncodingFilter`

## [[Interceptor]]와 비교

→ [[Filter vs Interceptor]]
