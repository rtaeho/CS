---
title: "XSS"
tags: [보안, XSS, 스크립팅]
status: published
---

공격자가 신뢰할 수 있는 웹사이트에 악성 스크립트를 삽입해 사용자 브라우저에서 실행되게 하는 공격이다.

## 공격 유형

- **저장형(Stored) XSS**: 악성 스크립트가 서버에 저장되어, 다른 사용자가 해당 페이지를 방문할 때 실행된다.
- **반사형(Reflected) XSS**: URL 파라미터 등으로 전달된 악성 스크립트가 서버 응답에 그대로 포함되어 실행된다.
- **DOM 기반 XSS**: 클라이언트 측 스크립트가 DOM을 동적으로 조작하는 과정에서 발생한다.

## 방어 방법

### 입력 검증과 출력 이스케이핑

사용자 입력을 검증하고, HTML로 출력할 때 특수 문자를 이스케이프한다.

```js
// ❌ 잘못된 방법
element.innerHTML = userInput;

// ✅ 올바른 방법
element.textContent = userInput; // 자동 이스케이프

// ✅ HTML이 필요한 경우 DOMPurify로 새니타이징
import DOMPurify from 'dompurify';

element.innerHTML = DOMPurify.sanitize(userInput);
```

### Content-Security-Policy(CSP)

브라우저가 실행을 허용할 컨텐츠 소스를 제한한다.

```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' https://trusted-cdn.com;">
```

### HttpOnly [[쿠키]]

`HttpOnly` 플래그를 설정하면 자바스크립트로 쿠키에 접근할 수 없어, 스크립트가 삽입되어도 쿠키 탈취를 막을 수 있다.

## [[CSRF]]와의 차이

XSS는 악성 스크립트를 페이지에 심어 쿠키를 직접 읽거나 사용자 정보를 탈취하는 반면, CSRF는 스크립트 삽입 없이 브라우저가 쿠키를 자동 전송하는 특성을 악용해 사용자 권한으로 원치 않는 요청을 실행시킨다.

## 핵심 정리

XSS는 저장형·반사형·DOM 기반으로 나뉘며, 공통 방어책은 출력 이스케이핑(또는 DOMPurify), CSP로 스크립트 출처 제한, HttpOnly 쿠키로 탈취 시 피해를 줄이는 것이다.

→ [[XSS 공격이란 무엇이며, 프론트엔드에서 이를 방어하기 위한 방법을 설명해주세요.]]
