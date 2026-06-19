---
title: "@ExceptionHandler"
tags: [Spring, 예외처리]
status: published
---

Spring MVC에서 특정 예외를 처리할 메서드를 지정하는 어노테이션입니다.

## 핵심 특징

- 컨트롤러 내부에 선언하면 해당 컨트롤러의 예외에만 적용됩니다
- [[@ControllerAdvice]] 클래스에 선언하면 모든 컨트롤러에 전역 적용됩니다
- 예외가 WAS로 전파되지 않고 메서드 내에서 직접 처리됩니다

## 동작 흐름

```
예외 발생
    ↓
[[DispatcherServlet]]이 [[HandlerExceptionResolver]]에 위임
    ↓
ExceptionHandlerExceptionResolver가 @ExceptionHandler 탐색
    ↓
매칭 메서드 실행 후 응답 반환
```

## 사용 예시

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> handleIllegal(IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }
}
```

## 핵심 정리

- [[@RestControllerAdvice]]와 함께 사용하면 JSON 형태의 에러 응답을 쉽게 구성할 수 있습니다
- 처리할 예외 타입을 어노테이션 속성으로 지정하거나 메서드 파라미터로 선언할 수 있습니다
