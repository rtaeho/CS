---
title: "Header"
tags: [HTTP, REST]
status: published
---

HTTP 메시지에서 본문(Body) 앞에 위치하며, 요청/응답에 대한 부가적인 메타정보를 담는 부분입니다.

## 구조

```
Key: Value
```

```http
Content-Type: application/json
Authorization: Bearer eyJhbGci...
Accept: application/json
```

## 헤더 분류

|분류|설명|예시|
|---|---|---|
|**요청 헤더**|클라이언트가 서버에 전달|`Authorization`, `Accept`, `Cookie`|
|**응답 헤더**|서버가 클라이언트에 전달|`Set-Cookie`, `Location`|
|**공통 헤더**|요청/응답 모두 사용|`Content-Type`, `Cache-Control`|

## 자주 쓰이는 헤더

|헤더|용도|
|---|---|
|`Content-Type`|Body 데이터 형식 명시|
|`Authorization`|인증 토큰 전달|
|`Accept`|클라이언트가 받을 수 있는 데이터 형식|
|`Cache-Control`|캐시 정책 설정|
|`Cookie` / `Set-Cookie`|쿠키 전달 / 설정|

## Java 예시 (Spring)

```java
// 요청 헤더 읽기
@GetMapping("/user")
public ResponseEntity<?> getUser(
    @RequestHeader("Authorization") String token) {
    // token = "Bearer eyJhbGci..."
}

// 응답 헤더 추가
HttpHeaders headers = new HttpHeaders();
headers.set("Custom-Header", "value");
return ResponseEntity.ok().headers(headers).body(data);
```

## Body와의 차이

||Header|Body|
|---|---|---|
|역할|메타정보|실제 데이터|
|크기|작음 (텍스트)|클 수 있음|
|항상 존재|O|X|