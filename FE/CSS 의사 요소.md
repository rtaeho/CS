---
title: "CSS 의사 요소"
tags: [CSS, 선택자, Frontend]
status: published
---

CSS 의사 요소는 선택자에 붙여 요소 자체가 아니라 요소의 특정 부분이나 가상의 일부에 스타일을 적용하는 문법입니다.

## 핵심 특징

- HTML 구조를 추가하지 않고 특정 부분에 스타일을 줄 수 있습니다.
- `::before`, `::after`처럼 가상 콘텐츠를 만들 수 있습니다.
- `::first-letter`, `::first-line`처럼 텍스트의 일부에만 스타일을 적용할 수 있습니다.
- 의사 요소는 보통 더블 콜론(`::`) 문법을 사용합니다.

## 예시

```css
button::before {
  content: "*";
  margin-right: 4px;
}

p::first-line {
  font-weight: bold;
}
```

`::before`와 `::after`는 `content` 속성과 함께 사용해 요소 앞뒤에 장식이나 보조 콘텐츠를 넣을 수 있습니다.

## 의사 요소 vs 의사 클래스

| 항목 | 의사 요소 | 의사 클래스 |
|---|---|---|
| 기준 | 요소의 특정 부분 | 요소의 상태나 조건 |
| 예시 | `::before`, `::after`, `::first-letter` | `:hover`, `:focus`, `:nth-child()` |
| 의미 | 어떤 부분인가 | 어떤 상태인가 |

## 주의사항

- 중요한 텍스트를 `content`로만 넣으면 접근성이나 복사, 검색 측면에서 불리할 수 있습니다.
- 장식 목적에는 적합하지만 의미 있는 콘텐츠는 HTML에 직접 표현하는 편이 좋습니다.
- `::before`, `::after`는 replaced element인 `img` 같은 요소에는 기대대로 동작하지 않을 수 있습니다.

## 핵심 정리

CSS 의사 요소는 HTML을 바꾸지 않고 요소의 특정 부분을 꾸미기 위한 선택자 문법입니다.

상태를 기준으로 하는 의사 클래스와 달리, 의사 요소는 요소 내부의 가상 부분이나 일부를 대상으로 합니다.

→ [[CSS 의사 요소(Pseudo-elements)란 무엇인가요]]
