Spring MVC의 DispatcherServlet 이후에서 동작하며, Controller 호출 전·후·완료 시점을 세분화해 공통 처리를 수행하는 컴포넌트입니다.

## 동작 위치

```
클라이언트 요청
    ↓
DispatcherServlet
    ↓
[ Interceptor preHandle ]  ← 여기 (Spring 안)
    ↓
Controller
    ↓
[ Interceptor postHandle ]
    ↓
View 렌더링
    ↓
[ Interceptor afterCompletion ]
    ↓
클라이언트 응답
```

## 구현

```java
@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {
        // Controller 호출 전 — false 반환 시 요청 차단
        String token = request.getHeader("Authorization");
        if (token == null) {
            response.sendError(401);
            return false;
        }
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request,
                           HttpServletResponse response,
                           Object handler,
                           ModelAndView modelAndView) throws Exception {
        // Controller 호출 후, View 렌더링 전
    }

    @Override
    public void afterCompletion(HttpServletRequest request,
                                HttpServletResponse response,
                                Object handler,
                                Exception ex) throws Exception {
        // View 렌더링 완료 후 — 예외 발생해도 반드시 호출됨
        // 리소스 정리, 실행 시간 측정 등
    }
}
```

## 등록

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final AuthInterceptor authInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
                .addPathPatterns("/api/**")
                .excludePathPatterns("/api/login");
    }
}
```

## 핵심 특징

- Spring Bean 자유롭게 주입 가능
- `handler` 파라미터로 어떤 Controller·메서드인지 확인 가능 (어노테이션 체크 등)
- 예외 발생 시 `@ControllerAdvice`로 잡힘
- `preHandle` → `postHandle` → `afterCompletion` 3단계 시점 제공

## 주요 사용 사례

- 로그인 여부 확인
- 권한 체크 (`@LoginRequired` 같은 커스텀 어노테이션과 조합)
- 실행 시간 측정
- 공통 데이터 주입 (`request.setAttribute`에 사용자 정보 세팅)

## [[Filter]]와 비교

→ [[Filter vs Interceptor]]
