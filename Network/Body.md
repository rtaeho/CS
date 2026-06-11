---
title: "Body"
tags: [HTTP, REST]
status: published
---

HTTP 메시지에서 실제 전송할 데이터(콘텐츠)를 담는 부분입니다.

## HTTP 메시지 구조

```
[Start Line]  → 요청/응답의 첫 줄 (메서드, URL, 상태코드 등)
[Headers]     → 메타정보 (Content-Type, Authorization 등)
[공백 라인]   → 헤더와 바디를 구분
[Body]        → 실제 데이터 ← 여기
```

## 특징

|항목|내용|
|---|---|
|필수 여부|선택적 (없을 수도 있음)|
|있는 경우|POST, PUT, PATCH 요청 / 대부분의 응답|
|없는 경우|GET, DELETE 요청 / 204 응답 등|
|형식 지정|`Content-Type` 헤더로 명시|

## 주요 Content-Type별 Body 형태

**application/json**

```json
{
  "userId": 1,
  "name": "홍길동"
}
```

**application/x-www-form-urlencoded**

```
userId=1&name=홍길동
```

**multipart/form-data**

```
파일 업로드 시 사용, 바이너리 데이터 포함 가능
```

## Java 예시 (Spring)

```java
// 요청 Body 받기
@PostMapping("/user")
public ResponseEntity<?> createUser(@RequestBody UserDto userDto) {
    // userDto에 Body의 JSON이 매핑됨
}

// 응답 Body 보내기
return ResponseEntity.ok(userDto); // 객체가 JSON으로 직렬화되어 Body에 담김
```

> **Body 크기**는 서버 설정으로 제한할 수 있으며, Spring Boot 기본값은 **2MB**입니다.