---
title: "CSS 전처리기"
tags: [CSS, 전처리기, Sass]
status: published
---

CSS 전처리기는 변수, 중첩, 믹스인, 함수 같은 확장 문법으로 스타일을 작성한 뒤 일반 CSS로 컴파일해 사용하는 도구입니다.

## 핵심 특징

- CSS에 변수, 중첩, 믹스인, 함수 같은 재사용 기능을 더합니다.
- 작성한 전처리기 코드는 빌드 단계에서 브라우저가 이해하는 CSS로 변환됩니다.
- 대표적인 도구로 Sass, Less, Stylus가 있습니다.
- 반복되는 스타일 규칙을 줄이고 디자인 토큰을 체계적으로 관리할 수 있습니다.

## Sass 예시

```scss
$button-padding: 10px 20px;
$border-radius: 4px;

@mixin button($bg-color) {
  background-color: $bg-color;
  color: white;
  padding: $button-padding;
  border-radius: $border-radius;
}

.primary-button {
  @include button(#007bff);
}
```

## CSS 전처리기 vs Zero Runtime CSS

| 항목 | CSS 전처리기 | [[제로 런타임 CSS]] |
|---|---|---|
| 등장 배경 | CSS 문법의 재사용성 보완 | CSS-in-JS의 런타임 비용 제거 |
| 작성 방식 | CSS와 유사한 확장 문법 | JavaScript/TypeScript 기반 스타일 작성 |
| 처리 시점 | 빌드 타임에 CSS 생성 | 빌드 타임에 CSS 추출 |
| 대표 도구 | Sass, Less, Stylus | vanilla-extract, Linaria |

## 주의사항

- 중첩을 과하게 사용하면 선택자 복잡도가 높아집니다.
- 전역 CSS와 함께 쓰면 의도치 않은 스타일 충돌이 생길 수 있습니다.
- 최신 CSS 자체도 변수, nesting, color 함수 등 기능이 늘고 있으므로 도입 이유를 점검해야 합니다.

## 핵심 정리

CSS 전처리기는 CSS 작성 생산성과 재사용성을 높이기 위한 도구입니다.

다만 최신 CSS와 CSS-in-JS, Zero Runtime CSS 같은 대안이 있으므로 프로젝트의 스타일링 방식과 빌드 환경에 맞춰 선택해야 합니다.

→ [[CSS 전처리기(CSS preprocessor)란 무엇인가요]]
