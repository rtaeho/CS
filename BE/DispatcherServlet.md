---
title: "DispatcherServlet"
tags: [Spring, MVC]
status: published
---

Spring MVC의 프론트 컨트롤러(Front Controller) 패턴을 구현한 서블릿으로, 모든 HTTP 요청을 중앙에서 받아 적절한 핸들러로 위임합니다.

## 요청 처리 흐름

```
HTTP 요청
    ↓
DispatcherServlet
    ↓
HandlerMapping (핸들러 결정)
    ↓
HandlerAdapter (핸들러 실행)
    ↓
ModelAndView 반환
    ↓
ViewResolver (뷰 결정)
    ↓
HTTP 응답
```

## 예외 처리 흐름

예외 발생 시 [[HandlerExceptionResolver]] 체인에 위임한다.

```
예외 발생
    ↓
DispatcherServlet
    ↓
ExceptionHandlerExceptionResolver (@ExceptionHandler 탐색)
    ↓
ResponseStatusExceptionResolver (@ResponseStatus 처리)
    ↓
DefaultHandlerExceptionResolver (Spring 표준 예외)
    ↓
처리 불가 → WAS로 전파
```

## 핵심 정리

- Spring MVC의 단일 진입점 (Front Controller 패턴)
- [[Filter]]는 DispatcherServlet 앞, [[Interceptor]]는 DispatcherServlet 내부에서 동작
- Spring Boot 자동 설정으로 별도 설정 없이 등록됨
