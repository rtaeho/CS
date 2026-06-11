---
title: "URL"
tags: [HTTP, URI]
status: published
---

인터넷에서 자원(Resource)의 **위치(주소)를 나타내는 문자열**로, 브라우저가 서버에서 자원을 찾을 수 있도록 경로를 지정합니다.

## 구성 요소

```
https://www.example.com:8080/users/1?name=kim#section
─────   ───────────────  ────  ───────  ────────  ───────
scheme      host         port   path    query   fragment
```

|요소|필수 여부|설명|예시|
|---|---|---|---|
|**scheme**|O|프로토콜|`https`, `http`, `ftp`|
|**host**|O|서버 주소|`www.example.com`|
|**port**|X|포트 번호 (생략 시 기본값)|`8080`|
|**path**|X|자원 경로|`/users/1`|
|**query**|X|추가 파라미터 (`?`로 시작)|`?name=kim`|
|**fragment**|X|페이지 내 특정 위치 (`#`로 시작)|`#section`|

## 기본 포트 번호

```
http  → 80  (생략 가능)
https → 443 (생략 가능)
ftp   → 21
```

## URL vs URI vs URN

||URL|URI|URN|
|---|---|---|---|
|**개념**|위치로 식별|식별자 전체|이름으로 식별|
|**관계**|URI의 하위|상위 개념|URI의 하위|
|**예시**|`https://example.com`|URL + URN|`urn:isbn:12345`|

## 자원 이동 시 문제

```
URL은 위치 기반이므로
자원의 위치가 바뀌면 → URL도 바뀜 → 링크 깨짐
(이를 보완하기 위해 URN 개념 존재)
```

> URL은 URI의 하위 개념으로, **모든 URL은 URI이지만 모든 URI가 URL은 아닙니다.**