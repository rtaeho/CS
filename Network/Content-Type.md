---
title: "Content-Type"
tags: [HTTP, Header, MIME]
status: published
---

Content-Type은 HTTP 요청이나 응답 본문에 담긴 데이터의 미디어 타입을 알려주는 헤더입니다.

## 역할

- 수신자가 Body를 어떤 형식으로 해석해야 하는지 알려줍니다.
- JSON, HTML, 파일 업로드 등 데이터 형식을 명시합니다.
- 잘못 지정하면 서버가 데이터를 잘못 파싱하거나 `415 Unsupported Media Type`을 반환할 수 있습니다.

## MIME 타입

Content-Type은 MIME 타입을 기반으로 하며 보통 `type/subtype` 형식을 사용합니다.

| 데이터 | Content-Type |
|---|---|
| JSON | `application/json` |
| HTML | `text/html` |
| Form | `application/x-www-form-urlencoded` |
| 파일 업로드 | `multipart/form-data` |

## Content-Type vs Accept

| 헤더 | 의미 |
|---|---|
| Content-Type | 지금 보내는 Body의 타입 |
| Accept | 응답으로 받고 싶은 타입 |

```http
POST /users HTTP/1.1
Content-Type: application/json
Accept: application/json
```

## 핵심 정리

Content-Type은 전송하는 데이터의 타입을 나타내고, Accept는 받고 싶은 응답 타입을 나타냅니다.

둘을 정확히 지정해야 클라이언트와 서버가 데이터를 올바르게 해석할 수 있습니다.

→ [[Content-Type 헤더에 대해서 설명해주세요]]
