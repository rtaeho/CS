Spring MVC에서 컨트롤러 메서드의 파라미터 값을 HTTP 요청으로부터 자동으로 생성하고 주입하는 컴포넌트다.

## 핵심 특징

- `HandlerMethodArgumentResolver` 인터페이스 구현체들의 집합
- `@RequestParam`, `@RequestBody`, `@PathVariable`, `@ModelAttribute`, `@SessionAttribute` 등 각 어노테이션마다 담당 구현체가 존재
- `@RequestBody` 처리 시 내부적으로 [[HttpMessageConverter]]를 호출해 HTTP 본문을 Java 객체로 변환
- [[HandlerAdapter]](RequestMappingHandlerAdapter)가 핸들러 실행 전에 ArgumentResolver를 호출

## 커스텀 ArgumentResolver 예시

```java
public class LoginUserArgumentResolver implements HandlerMethodArgumentResolver {
    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(LoginUser.class);
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ...) {
        // 세션 등에서 사용자 정보 추출
        return session.getAttribute("user");
    }
}
```

## 핵심 정리

ArgumentResolver는 컨트롤러 파라미터 바인딩을 담당하는 확장 포인트로, 커스텀 구현으로 어노테이션 기반 파라미터 주입을 추가할 수 있다.
