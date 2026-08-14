---
title: "JSX"
tags: [React, 트랜스파일링, 선언적UI]
status: published
---

JavaScript XML의 약자로, React에서 UI를 선언적으로 표현하기 위해 사용하는 자바스크립트의 확장 문법입니다.

## 핵심 특징

- HTML과 유사한 문법으로 JavaScript 코드 안에서 UI 구조를 직관적으로 표현할 수 있습니다.
- 브라우저에서 직접 실행할 수 없고, Babel 같은 [[트랜스파일링|트랜스파일러]]를 거쳐 일반 JavaScript 코드로 변환된 후 실행됩니다.
- React 전용 문법이 아니라 단순한 문법 확장이므로, JSX를 지원하는 다른 라이브러리에서도 활용할 수 있습니다.

## 트랜스파일 결과

```jsx
// 입력 (JSX)
const element = (
  <h1 className="greeting">
    Hello, JSX!
  </h1>
);
```

```jsx
// 트랜스파일 후 (JavaScript)
const element = React.createElement(
  'h1',
  { className: 'greeting' },
  'Hello, world!'
);
```

`React.createElement()`는 React의 핵심 API로, [[Virtual DOM]] 요소를 생성하는 역할을 합니다. 이를 통해 React는 요소를 트리 구조로 관리하고, 변경 사항을 효율적으로 감지해 실제 DOM에 반영합니다.

## 하나의 부모 요소로 감싸야 하는 이유

JavaScript 문법상 하나의 함수는 배열로 감싸지 않은 두 개의 객체를 반환할 수 없습니다. JSX도 결국 내부적으로 하나의 JavaScript 객체(`React.createElement()` 호출)로 변환되기 때문에, 여러 태그를 반환하려면 하나의 태그나 Fragment로 감싸야 합니다.

```jsx
// 오류 - 두 개의 최상위 요소
return (
  <h1>제목</h1>
  <p>내용</p>
);

// 정상 - Fragment로 감쌈
return (
  <>
    <h1>제목</h1>
    <p>내용</p>
  </>
);
```

## 핵심 정리

JSX는 UI를 선언적으로 표현하기 위한 자바스크립트 확장 문법으로, 그 자체로는 실행되지 않고 트랜스파일러를 거쳐 `React.createElement()` 호출로 변환됩니다. 결과적으로 하나의 JavaScript 객체로 귀결되기 때문에, 여러 요소를 반환하려면 반드시 하나의 루트로 감싸야 합니다.

→ [[jsx란 무엇이며, 이는 자바스크립트에서 어떻게 변환되나요?]]
