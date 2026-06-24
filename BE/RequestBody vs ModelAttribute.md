---
title: "RequestBody vs ModelAttribute"
tags: [Spring, HTTP, 바인딩]
status: published
---

Spring MVC에서 클라이언트 요청 데이터를 Java 객체로 바인딩할 때 사용하는 두 방식의 차이를 설명하는 개념입니다.

## 핵심 차이

- **`@RequestBody`**: HTTP 요청 본문을 읽어 객체로 변환
- **`@ModelAttribute`**: 요청 파라미터, 쿼리 스트링, form-data를 객체에 바인딩
- **변환 경로**: `@RequestBody`는 [[HttpMessageConverter]], `@ModelAttribute`는 데이터 바인더와 `ModelAttributeMethodProcessor`를 주로 사용
- **대표 사용처**: JSON API는 `@RequestBody`, HTML form이나 파일 업로드는 `@ModelAttribute`

## @RequestBody

`@RequestBody`는 요청 본문에 담긴 JSON, XML 같은 데이터를 Java 객체로 역직렬화합니다.

```java
@PostMapping("/members")
public ResponseEntity<Void> create(@RequestBody MemberRequest request) {
    memberService.create(request);
    return ResponseEntity.ok().build();
}
```

Spring은 요청의 `Content-Type`을 보고 적절한 `HttpMessageConverter`를 선택합니다. JSON 요청이라면 보통 Jackson `ObjectMapper`가 객체 생성을 담당합니다.

## @ModelAttribute

`@ModelAttribute`는 쿼리 파라미터나 form-data를 객체의 필드에 바인딩합니다.

```java
@GetMapping("/members")
public List<MemberResponse> search(@ModelAttribute MemberSearchCondition condition) {
    return memberService.search(condition);
}
```

```java
@PostMapping("/profiles")
public ResponseEntity<Void> upload(@ModelAttribute ProfileForm form) {
    profileService.upload(form);
    return ResponseEntity.ok().build();
}
```

파일 업로드처럼 `multipart/form-data`가 섞인 요청에는 `@ModelAttribute`가 자연스럽습니다.

## RequestBody vs ModelAttribute

| 항목 | @RequestBody | @ModelAttribute |
|---|---|---|
| 대상 | 요청 본문 | 요청 파라미터, form-data |
| 대표 Content-Type | `application/json` | `application/x-www-form-urlencoded`, `multipart/form-data` |
| 변환 방식 | `HttpMessageConverter` | 데이터 바인딩 |
| 주 사용처 | REST API JSON 요청 | 검색 조건, HTML form, 파일 업로드 |

## 주의사항

- `@RequestBody`는 요청 본문을 한 번 읽어 변환하므로 GET 검색 조건에는 과한 경우가 많음
- `@ModelAttribute`는 기본적으로 파라미터 이름과 객체 필드 이름이 맞아야 함
- JSON 요청인데 `@ModelAttribute`를 쓰거나, form-data 요청인데 `@RequestBody`를 쓰면 바인딩 실패가 발생하기 쉬움
- record DTO는 Jackson이 canonical constructor를 활용해 역직렬화할 수 있음

## 핵심 정리

JSON 본문을 객체로 받을 때는 `@RequestBody`,
쿼리 파라미터나 form-data를 객체로 받을 때는 `@ModelAttribute`가 적합합니다.

둘 다 요청 데이터를 객체로 바꾸지만,
읽는 위치와 변환 메커니즘이 다릅니다.

→ [[RequestBody VS ModelAttribute의 차이점을 말해주세요]]
