---
title: "Reset CSS와 Normalize CSS가 무엇인가요"
tags: [매일메일, Frontend]
status: published
---

웹 개발에서는 브라우저가 제공하는 기본 스타일이 서로 다를 수 있기 때문에, 이를 통일하여 일관된 디자인을 구현하는 것이 중요합니다. [[Reset CSS]]와 [[Normalize CSS]]는 모두 브라우저 간의 스타일 차이를 줄이기 위해 사용되는 CSS 파일입니다. 두 방법은 목적이 같지만 방식에 차이가 있습니다.

## Reset CSS

Reset CSS는 모든 브라우저의 기본 스타일을 완전히 제거하는 방식입니다. 예를 들어 HTML 요소에 기본적으로 적용된 여백, 패딩, 글자 크기 등을 초기화하여 모든 요소를 스타일이 거의 없는 상태로 만듭니다.

```css
* {
  margin: 0;
  padding: 0;
  border: 0;
  font-size: 100%;
  font: inherit;
  vertical-align: baseline;
}
```

이렇게 하면 개발자는 특정 브라우저의 기본 스타일에 영향을 받지 않고 통제된 상태에서 스타일링을 시작할 수 있습니다. 다만 모든 요소를 초기화하기 때문에 스타일을 처음부터 새롭게 작성해야 하는 수고가 있습니다.

## Normalize CSS

Normalize CSS는 브라우저 간 스타일 차이를 줄이는 데 중점을 둔 방식입니다. 모든 요소의 기본 스타일을 완전히 제거하는 대신, 브라우저 간에 일관되지 않은 스타일만 수정하여 자연스러운 기본값을 유지합니다.

```css
h1 {
  font-size: 2em;
  margin: 0.67em 0;
}

a {
  background-color: transparent;
}
```

제목 태그의 기본 크기나 링크 스타일처럼 유용한 기본 스타일은 유지하면서 주요 차이만 해소합니다.

## 둘 중 어떤 방식을 선택하는 것이 좋나요?

프로젝트 상황이나 팀의 스타일링 전략에 따라 다릅니다.

[[Reset CSS]]는 스타일 통일성을 확실하게 보장할 수 있지만, 처음부터 다시 스타일링해야 합니다. 반면 [[Normalize CSS]]는 기본 스타일을 유지해 빠르게 시작하기 좋지만, 통제력은 상대적으로 낮습니다.

디자인 시스템처럼 모든 스타일을 직접 관리해야 하는 상황에서는 Reset CSS가 유리하고, 데드라인이 짧거나 콘텐츠 중심 페이지처럼 브라우저 기본 스타일을 활용해도 괜찮은 상황에서는 Normalize CSS가 유리할 수 있습니다.

## 추가 학습 자료

- [DaleSeo - CSS Normalize와 CSS Reset](https://www.daleseo.com/css-normalize-reset/)
- [디자인 베이스 - Reset.css & Normalize.css](https://www.youtube.com/watch?v=DpES7X-xgUc)

관련 비교는 [[Reset CSS vs Normalize CSS]]에서 볼 수 있습니다.
