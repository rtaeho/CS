[[DispatcherServlet]]이 [[HandlerMapping]]으로 찾은 핸들러를 실제로 실행할 수 있도록 어댑터 역할을 수행하는 컴포넌트입니다.

## 핵심 특징

- 다양한 핸들러 유형(어노테이션 컨트롤러, `HttpRequestHandler`, `Controller` 인터페이스 등)을 동일한 인터페이스로 처리
- `@RequestMapping` 기반 컨트롤러는 `RequestMappingHandlerAdapter`가 처리
- [[ArgumentResolver]]를 이용해 컨트롤러 메서드 파라미터를 HTTP 요청으로부터 생성
- `ReturnValueHandler`를 이용해 컨트롤러 반환값을 ModelAndView 또는 [[HttpMessageConverter]] 응답으로 변환

## 주요 구현체

| 구현체 | 처리 대상 |
|---|---|
| `RequestMappingHandlerAdapter` | `@RequestMapping` 어노테이션 컨트롤러 |
| `HttpRequestHandlerAdapter` | `HttpRequestHandler` 구현체 |
| `SimpleControllerHandlerAdapter` | `Controller` 인터페이스 구현체 |

## 핵심 정리

HandlerAdapter는 DispatcherServlet과 실제 컨트롤러 사이의 어댑터 레이어로, 다양한 컨트롤러 유형을 단일 인터페이스로 위임합니다.
