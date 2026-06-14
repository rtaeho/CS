---
title: "HandlerExceptionResolver"
tags: [Spring, ExceptionHandler]
status: published
---

Spring MVC에서 컨트롤러 처리 중 발생한 예외를 처리하는 전략 인터페이스입니다.

## 기본 등록 구현체 (우선순위 순)

| 순위 | 구현체 | 처리 대상 |
|---|---|---|
| 1 | ExceptionHandlerExceptionResolver | `@ExceptionHandler` 메서드 |
| 2 | ResponseStatusExceptionResolver | `@ResponseStatus` 예외 |
| 3 | DefaultHandlerExceptionResolver | Spring 표준 예외 |

## 동작 방식

[[DispatcherServlet]]이 예외를 받으면 등록된 리졸버를 순서대로 호출한다. 처리 가능한 리졸버가 응답을 작성하면 전파가 멈추고, 아무 리졸버도 처리하지 못하면 예외가 WAS로 전파된다.

## 핵심 정리

- ExceptionHandlerExceptionResolver가 가장 먼저 동작
- [[@ControllerAdvice]]의 `@ExceptionHandler`는 전역, [[@Controller]] 내 `@ExceptionHandler`는 해당 컨트롤러에만 적용
- 예외가 처리되면 WAS로 전파되지 않음
