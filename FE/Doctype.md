---
title: "Doctype"
tags: [HTML]
status: published
---

[[HTML]] 문서의 **최상단에 위치하는 선언문**으로, 브라우저에게 해당 문서가 어떤 버전의 HTML로 작성되었는지 알려주는 역할을 합니다.

## 기본 형태

```html
<!DOCTYPE html>  ← HTML5 선언
<html>
  ...
</html>
```

## 왜 필요한가?

```
DOCTYPE 없으면 → 브라우저가 "quirks mode"로 렌더링
→ 브라우저마다 다르게 해석 → 레이아웃 깨짐

DOCTYPE 있으면 → "standards mode"로 렌더링
→ 표준에 맞게 일관된 렌더링 O
```

## 렌더링 모드

|모드|설명|
|---|---|
|**Standards Mode**|W3C 표준에 따라 렌더링|
|**Quirks Mode**|구형 브라우저 방식으로 렌더링 (비표준)|
|**Almost Standards Mode**|표준에 가깝지만 일부 quirks 허용|

## 버전별 DOCTYPE

```html
<!-- HTML5 (현재 표준) -->
<!DOCTYPE html>

<!-- HTML 4.01 Strict -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd">

<!-- XHTML 1.0 -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
```

## HTML5에서의 변화

```
이전: DTD(문서 타입 정의) URL을 길게 명시해야 함
HTML5: <!DOCTYPE html> 한 줄로 단순화
→ 버전 구분 없이 최신 표준으로 렌더링
```

> `<!DOCTYPE html>`은 HTML 태그가 아니라 **브라우저에 대한 지시문**으로, 반드시 HTML 문서의 **가장 첫 줄**에 위치해야 합니다.