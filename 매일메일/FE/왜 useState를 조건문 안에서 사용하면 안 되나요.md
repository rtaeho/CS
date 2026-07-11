---
title: "왜 useState를 조건문 안에서 사용하면 안 되나요"
tags: [매일메일, Frontend]
status: published
---

`useState()`를 조건문 안에서 사용하면 안 되는 이유는 React가 [[useState]] 같은 Hook을 호출 순서에 따라 관리하기 때문입니다.

## React의 상태 관리 방식

React는 컴포넌트가 렌더링될 때 Hook이 호출되는 순서를 기준으로 각각의 상태를 연결합니다. 첫 번째 `useState`, 두 번째 `useState`처럼 순서로 상태 슬롯을 매칭하는 방식입니다.

## 조건문 안에서 호출할 때의 문제

```jsx
function Example({ shouldUseState }) {
  if (shouldUseState) {
    const [count, setCount] = useState(0);
  }

  return <div>Example Component</div>;
}
```

위 코드에서 `shouldUseState`가 `true`일 때는 `useState()`가 호출되지만, `false`가 되면 호출되지 않습니다. 렌더링마다 Hook 호출 개수가 달라지면 React가 이전 상태와 현재 Hook을 올바르게 연결할 수 없습니다.

## 올바른 방식

Hook은 항상 컴포넌트 최상위에서 호출하고, 조건은 Hook 호출 이후에 처리해야 합니다.

```jsx
function Example({ shouldShow }) {
  const [count, setCount] = useState(0);

  if (!shouldShow) {
    return null;
  }

  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

## 정리

`useState()`는 [[Hook의 규칙]]에 따라 조건문이나 반복문 안이 아니라 컴포넌트 최상위에서 호출해야 합니다. 그래야 렌더링마다 Hook 호출 순서가 유지되고, React가 상태를 안정적으로 추적할 수 있습니다.

## 추가 학습 자료

- [React - Hook의 규칙](https://ko.legacy.reactjs.org/docs/hooks-rules.html)
- [React useState 동작 원리 이해하기](https://d5br5.dev/blog/deep_dive/react_useState_understanding)
