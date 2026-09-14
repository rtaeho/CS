---
title: "useEffect 실행 순서"
tags: [React, useEffect, 렌더링]
status: published
---

컴포넌트 트리에서 `useEffect`는 렌더링과 별개의 순서 규칙을 가지며, 부모-자식 관계에서 함수 실행 순서와 effect 실행 순서가 서로 반대로 동작합니다.

## 렌더 단계: 부모 → 자식

함수 컴포넌트의 본문(state, props를 이용한 JSX 계산)은 트리를 따라 **부모가 먼저, 자식이 나중에** 실행됩니다. 부모 함수가 실행되며 자식 컴포넌트를 만나는 시점에 자식 함수가 호출되기 때문입니다.

```jsx
function Parent() {
  console.log('1'); // 부모 먼저
  return <Child />;
}

function Child() {
  console.log('2'); // 자식 나중
  return null;
}
```

## 커밋 단계: 자식 → 부모

`useEffect` 콜백은 [[리액트 리렌더링 과정]]의 Commit 단계 이후, DOM이 실제로 갱신된 뒤 실행됩니다. DOM은 자식이 먼저 붙고 부모가 나중에 완성되므로, effect도 **자식이 먼저, 부모가 나중에** 실행됩니다. 렌더 단계와는 정반대 순서입니다.

```jsx
function Parent() {
  useEffect(() => {
    console.log('parent effect'); // 나중
  });
  return <Child />;
}

function Child() {
  useEffect(() => {
    console.log('child effect'); // 먼저
  });
  return null;
}
```

## 리렌더링 시 cleanup 순서

의존성 배열의 값이 바뀌어 effect가 재실행될 때, 리액트는 **새 effect를 실행하기 전에 이전 effect의 cleanup 함수를 먼저 호출**합니다.

```jsx
useEffect(() => {
  console.log('effect');
  return () => {
    console.log('cleanup'); // 다음 effect보다 먼저 호출됨
  };
}, [count]);
```

의존성 배열이 빈 배열(`[]`)이면 마운트 시 한 번만 실행되고, 리렌더링 때는 재실행도 cleanup도 일어나지 않습니다. 언마운트 시에만 cleanup이 호출됩니다.

## 핵심 정리

- 컴포넌트 함수 본문(렌더)은 부모 → 자식 순서로 실행됩니다.
- `useEffect` 콜백(커밋 이후)은 자식 → 부모 순서로 실행되어 렌더 순서와 반대입니다.
- 의존성이 바뀌어 effect가 재실행될 때는 새 effect보다 이전 cleanup이 먼저 호출됩니다.
- 빈 의존성 배열은 마운트 때만 실행되며, 리렌더링에는 영향받지 않습니다.

→ [[다음 리액트 코드의 실행 순서에 대해 설명해주세요]]
