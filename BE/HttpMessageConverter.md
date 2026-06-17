Spring MVC에서 HTTP 요청 본문을 Java 객체로, Java 객체를 HTTP 응답 본문으로 변환하는 인터페이스다.

## 핵심 특징

- `@RequestBody`, `@ResponseBody`, `ResponseEntity` 사용 시 동작하며 [[뷰 리졸버]]를 거치지 않음
- Content-Type 헤더(요청 변환)와 Accept 헤더(응답 변환)를 기반으로 적절한 구현체를 자동 선택
- [[ArgumentResolver]]가 요청 본문 변환에, `ReturnValueHandler`가 응답 본문 변환에 사용
- 요청/응답 두 방향 모두 사용 가능

## 주요 구현체

| 구현체 | 처리 미디어 타입 |
|---|---|
| `MappingJackson2HttpMessageConverter` | `application/json` |
| `StringHttpMessageConverter` | `text/plain`, `text/*` |
| `ByteArrayHttpMessageConverter` | `application/octet-stream` |
| `FormHttpMessageConverter` | `application/x-www-form-urlencoded` |

## 핵심 정리

HttpMessageConverter는 REST API의 핵심 구성 요소로, Java 객체와 HTTP 본문 사이의 직렬화/역직렬화를 담당한다.
