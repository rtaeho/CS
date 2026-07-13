---
title: "CSS 의사 요소(Pseudo-elements)란 무엇인가요"
tags: [매일메일, Frontend]
status: published
---

[[CSS 의사 요소]]는 CSS 선택자에 추가하는 키워드로, 요소 전체가 아니라 특정 부분이나 가상의 일부에 스타일을 적용할 때 사용합니다.

## 대표 예시

`::before`와 `::after`는 요소의 앞이나 뒤에 가상 콘텐츠를 삽입할 때 자주 사용합니다.

```css
button::before {
  content: "*";
  margin-right: 5px;
}
```

`::first-letter`, `::first-line`은 텍스트의 첫 글자나 첫 줄처럼 요소 내부의 일부에만 스타일을 적용합니다.

## 의사 요소와 의사 클래스의 차이

의사 요소는 요소의 특정 부분을 대상으로 합니다. 반면 의사 클래스는 요소의 상태나 조건을 기준으로 스타일을 적용합니다.

| 구분 | 예시 | 기준 |
|---|---|---|
| 의사 요소 | `::before`, `::after` | 어떤 부분인가 |
| 의사 클래스 | `:hover`, `:focus` | 어떤 상태인가 |

## 정리

의사 요소는 HTML 구조를 바꾸지 않고도 요소의 일부를 꾸미거나 가상 콘텐츠를 표현할 수 있게 해줍니다. 다만 의미 있는 콘텐츠는 접근성을 위해 HTML에 직접 작성하는 편이 좋습니다.

## 추가 학습 자료

- [TCP School - 의사 요소](https://www.tcpschool.com/css/css_selector_pseudoElement)
- [TCP School - 의사 클래스](https://www.tcpschool.com/css/css_selector_pseudoClass)
