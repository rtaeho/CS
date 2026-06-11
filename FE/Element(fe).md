---
title: "Element(fe)"
tags: [DOM, JavaScript]
status: published
---

DOM에서 **HTML 태그에 해당하는 Node**로, Node의 하위 개념입니다.

## [[Node(fe)]]와의 관계

```
Node (상위 개념)
├── Element Node  ← HTML 태그 (<div>, <p> 등)
├── Text Node     ← 텍스트 내용
├── Comment Node  ← 주석
└── Document Node ← 최상위
```

## Element 특징

```html
<div class="box" id="main">내용</div>
 ─── ──────────────────────
 태그명        속성들
 → 이 전체가 Element
```

## Node vs Element 차이

```javascript
<div>
  Hello  ← Text Node (Node O, Element X)
  <span>World</span>  ← Element Node (Node O, Element O)
</div>

const div = document.querySelector('div');

div.childNodes  // [Text("Hello"), span] → Node 기준 (Text 포함)
div.children    // [span]               → Element 기준 (Element만)

div.firstChild          // Text Node ("Hello")
div.firstElementChild   // <span> Element
```

## 주요 속성/메서드

```javascript
const el = document.querySelector('.box');

// 속성
el.tagName        // "DIV"
el.id             // "main"
el.className      // "box"
el.classList      // ["box"]
el.innerHTML      // 내부 HTML 문자열
el.textContent    // 내부 텍스트

// 탐색
el.parentElement        // 부모 Element
el.children             // 자식 Element 목록
el.nextElementSibling   // 다음 형제 Element

// 조작
el.setAttribute('class', 'new')  // 속성 변경
el.removeAttribute('id')         // 속성 제거
el.append(newEl)                 // 자식 추가
el.remove()                      // 제거
```

## 정리

```
Node    → DOM의 모든 구성 요소 (Text, Comment 등 포함)
Element → Node 중 HTML 태그인 것만
```

> **Element는 Node의 하위 개념**으로, 일반적으로 DOM 조작 시 Text Node보다 Element를 다루는 경우가 많아 `children`, `firstElementChild` 등 Element 전용 API를 주로 사용합니다.