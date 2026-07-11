---
title: "Hook의 규칙"
tags: [React, Hook, useState]
status: published
---

Hook의 규칙은 React가 Hook 호출 순서를 기준으로 상태와 효과를 연결할 수 있도록 Hook을 항상 같은 순서로 호출해야 한다는 규칙입니다.

## 핵심 규칙

- Hook은 컴포넌트 최상위에서만 호출합니다.
- 조건문, 반복문, 중첩 함수 안에서 Hook을 호출하지 않습니다.
- Hook은 React 함수 컴포넌트나 Custom Hook 안에서만 호출합니다.

## 왜 순서가 중요한가

React는 Hook 호출 순서에 따라 각 Hook의 상태 슬롯을 연결합니다. 렌더링마다 Hook 호출 개수나 순서가 달라지면 이전 상태와 현재 Hook이 잘못 매칭될 수 있습니다.

```jsx
function Example({ enabled }) {
  if (enabled) {
    const [count, setCount] = useState(0);
  }

  const [name, setName] = useState("");
}
```

첫 렌더링에서 `enabled`가 `true`였다가 다음 렌더링에서 `false`가 되면 첫 번째 `useState` 호출이 사라집니다. 그러면 React가 기억하던 상태 슬롯과 Hook 호출 순서가 어긋날 수 있습니다.

## 올바른 방식

조건은 Hook 호출 안이 아니라 Hook 호출 이후 로직에서 처리합니다.

```jsx
function Example({ enabled }) {
  const [count, setCount] = useState(0);
  const [name, setName] = useState("");

  if (!enabled) {
    return null;
  }

  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

## 핵심 정리

Hook은 React가 호출 순서를 기준으로 상태를 추적하기 때문에 항상 같은 순서로 호출되어야 합니다.

조건문 안에서 Hook을 호출하지 말고, Hook 호출 이후 조건부 렌더링이나 조건부 로직을 작성해야 합니다.

→ [[왜 useState를 조건문 안에서 사용하면 안 되나요]]
