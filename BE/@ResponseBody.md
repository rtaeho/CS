`@ResponseBody`는 Spring MVC 컨트롤러 메서드의 반환값을 [[HttpMessageConverter]]로 직렬화해 HTTP 응답 본문에 직접 쓰는 어노테이션이다.

## 핵심 특징
- 메서드 또는 클래스 레벨에 선언 가능
- [[뷰 리졸버]]를 거치지 않음 — 반환값이 뷰 이름으로 해석되지 않음
- `Accept` 헤더와 등록된 [[HttpMessageConverter]] 목록을 기반으로 응답 Content-Type이 결정됨
- `@RestController` = `@Controller` + `@ResponseBody` (메타 어노테이션)

## 동작 흐름
```
컨트롤러 반환값
→ HttpMessageConverter 목록 순회
→ 쓰기 가능한 Converter 선택 (e.g. MappingJackson2HttpMessageConverter)
→ 응답 본문 직렬화 (JSON / XML 등)
```

## 핵심 정리
`@ResponseBody`를 붙이지 않으면 반환 String은 [[뷰 리졸버]]에게 전달되어 템플릿 이름으로 해석된다.
