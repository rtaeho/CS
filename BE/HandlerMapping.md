Spring MVC에서 HTTP 요청 URL을 처리할 핸들러(컨트롤러 메서드)를 찾아 [[DispatcherServlet]]에 반환하는 컴포넌트다.

## 핵심 특징

- `@RequestMapping`, `@GetMapping` 등의 어노테이션을 스캔해 URL-핸들러 매핑 정보를 구성
- 주요 구현체: `RequestMappingHandlerMapping`(어노테이션 기반), `BeanNameUrlHandlerMapping`(빈 이름 기반)
- 요청이 들어오면 DispatcherServlet이 등록된 HandlerMapping 목록을 순회해 우선순위에 따라 핸들러를 조회
- URL 매핑 외에도 HTTP 메서드, 파라미터, 헤더 조건으로 추가 필터링 가능

## 동작 흐름

```
HTTP 요청
    ↓
DispatcherServlet
    ↓ (순회)
HandlerMapping 목록
    ↓ (조회 성공)
HandlerExecutionChain (핸들러 + 인터셉터 목록)
    ↓
HandlerAdapter
```

## 핵심 정리

HandlerMapping은 URL → 핸들러 탐색을 담당하고, 찾은 핸들러를 [[HandlerAdapter]]에 전달해 실행한다.
