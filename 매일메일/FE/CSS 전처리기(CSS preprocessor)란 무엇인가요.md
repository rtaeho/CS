---
title: "CSS 전처리기(CSS preprocessor)란 무엇인가요"
tags: [매일메일, Frontend]
status: published
---

[[CSS 전처리기]]는 CSS를 더 효율적이고 체계적으로 작성할 수 있도록 도와주는 도구입니다. CSS에 변수, 중첩, 믹스인, 함수 같은 프로그래밍적 기능을 추가하고, 최종적으로는 일반 CSS로 컴파일해 브라우저에서 사용합니다.

## 왜 사용하는가

CSS는 기본적으로 스타일 규칙을 선언하는 문법을 제공합니다. 하지만 규모가 커지면 색상, 간격, 버튼 스타일처럼 반복되는 규칙이 많아집니다. CSS 전처리기를 사용하면 이런 반복을 변수와 믹스인으로 줄일 수 있습니다.

## 예시

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

.secondary-button {
  @include button(#6c757d);
}
```

## CSS 전처리기와 Zero Runtime CSS의 차이

둘 다 빌드 타임에 CSS를 생성할 수 있지만 목적이 다릅니다. CSS 전처리기는 순수 CSS의 재사용성과 구조화 한계를 보완하기 위해 등장했습니다. 반면 [[제로 런타임 CSS]]는 CSS-in-JS의 런타임 연산 비용을 줄이기 위해 컴파일 타임에 스타일을 추출합니다.

## 정리

CSS 전처리기는 CSS에 변수, 중첩, 믹스인 같은 기능을 더해 스타일 코드의 재사용성과 관리성을 높입니다. 다만 최신 CSS와 다른 스타일링 도구가 발전하고 있으므로, 프로젝트 상황에 맞춰 선택해야 합니다.

## 추가 학습 자료

- [F-lab - 현대 웹 개발에서의 CSS 전처리기의 역할과 중요성](https://f-lab.kr/insight/role-of-css-preprocessors-in-modern-web-development)
- [드림코딩 - CSS 핫 트렌드](https://www.youtube.com/watch?v=Eim11QYLfEY)
