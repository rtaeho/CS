---
title: "@RestControllerAdvice"
tags: [Spring, 예외처리, REST]
status: published
---

[[@ControllerAdvice]]와 [[@ResponseBody]]를 결합한 어노테이션으로, REST API에서 전역 예외 처리 시 반환 객체를 자동으로 JSON으로 직렬화합니다.

## 핵심 특징

- `@ControllerAdvice` + `@ResponseBody`의 합성입니다
- [[@ExceptionHandler]] 메서드의 반환 객체가 자동으로 JSON으로 변환됩니다
- [[@Component]]가 포함되어 있어 컴포넌트 스캔으로 빈에 등록됩니다

## @ControllerAdvice와 비교

| 어노테이션 | 응답 형태 |
|---|---|
| `@ControllerAdvice` | 뷰 이름 반환 또는 `@ResponseBody` 별도 필요 |
| `@RestControllerAdvice` | 반환 객체가 자동으로 JSON 직렬화 |

## 사용 예시

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ErrorResponse handleIllegal(IllegalArgumentException e) {
        return new ErrorResponse(400, e.getMessage());
    }
}
```

## 핵심 정리

- REST API 서버에서는 `@RestControllerAdvice`를 사용하는 것이 일반적입니다
- `@ResponseStatus`와 함께 사용하면 HTTP 상태 코드도 함께 제어할 수 있습니다
