---
title: "@ControllerAdvice"
tags: [Spring, ExceptionHandler]
status: published
---

여러 [[@Controller]]에 걸쳐 전역 예외 처리, 데이터 바인딩, 모델 속성 공유를 담당하는 [[어노테이션]]입니다.

## 주요 기능

| 기능 | 사용 어노테이션 |
|---|---|
| 예외 처리 | `@ExceptionHandler` |
| 데이터 바인딩 | `@InitBinder` |
| 모델 속성 공유 | `@ModelAttribute` |

## 기본 사용 예시

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> handleIllegal(IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }
}
```

## @RestControllerAdvice

`@ControllerAdvice` + `@ResponseBody`의 결합입니다. REST API에서 JSON 에러 응답을 반환할 때 사용합니다.

## 핵심 정리

- 모든 `@Controller`에 적용되는 전역 예외 처리 설정
- `@ExceptionHandler`와 함께 사용해 일관된 에러 응답 처리 가능
- [[DispatcherServlet]]이 예외를 위임하면 [[HandlerExceptionResolver]]가 이 클래스를 탐색

→ [[ControllerAdvice에 대해 설명해주세요]]
