---
title: "Content-Type 헤더에 대해서 설명해주세요"
tags: [매일메일, Frontend]
status: published
---

[[Content-Type]]은 HTTP 요청과 응답에서 전송되는 데이터의 타입을 명시하는 헤더입니다. 서버와 클라이언트가 Body를 올바르게 해석하기 위해 사용합니다.

## 예시

JSON 데이터를 보낼 때는 다음처럼 지정합니다.

```http
Content-Type: application/json
```

서버는 이 값을 보고 요청 본문을 JSON으로 파싱할 수 있습니다. HTML 응답에서는 `text/html`을 지정하면 브라우저가 문서를 HTML로 렌더링합니다.

## MIME 타입

Content-Type은 MIME 타입을 기반으로 하며 `[type]/[subtype]` 형식입니다.

| 데이터 | MIME 타입 |
|---|---|
| JSON | `application/json` |
| HTML | `text/html` |
| Form | `application/x-www-form-urlencoded` |
| 파일 업로드 | `multipart/form-data` |

## Content-Type과 Accept의 차이

`Content-Type`은 지금 전송하는 데이터의 타입입니다. 반면 `Accept`는 클라이언트가 응답으로 받고 싶은 데이터 타입을 나타냅니다.

```http
Content-Type: application/json
Accept: application/json
```

## 정리

Content-Type을 정확히 지정하지 않으면 서버나 클라이언트가 데이터를 잘못 해석할 수 있습니다. JSON을 보내면서 다른 타입을 지정하면 파싱 오류나 `415 Unsupported Media Type`이 발생할 수 있습니다.

## 추가 학습 자료

- [MDN - Content-Type](https://developer.mozilla.org/ko/docs/Web/HTTP/Headers/Content-Type)
- [MIME type은 뭐고, Content-type은 뭔데?](https://velog.io/@rookieand/MIME-type%EC%9D%80-%EB%AD%90%EA%B3%A0-Content-type%EC%9D%80-%EB%AD%94%EB%8D%B0)
