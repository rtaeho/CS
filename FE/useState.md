---
title: "useState"
tags: [React, Hook]
status: published
---

React에서 **컴포넌트의 상태(state)를 관리**하고, 상태가 변경되면 **자동으로 리렌더링**을 트리거하는 Hook입니다.

## 기본 사용법

```jsx
const [state, setState] = useState(초기값);
//     ↑         ↑
//   현재 상태   상태 변경 함수
```

## 기본 예시

```jsx
function Counter() {
    const [count, setCount] = useState(0);

    return (
        <div>
            <p>{count}</p>
            <button onClick={() => setCount(count + 1)}>+1</button>
            <button onClick={() => setCount(count - 1)}>-1</button>
        </div>
    );
}
```

## setState 동작 방식

```jsx
// 1. 직접 값 전달
setCount(5);

// 2. 함수형 업데이트 (이전 값 기반으로 변경 시 권장)
setCount(prev => prev + 1);  // O 이전 값 보장
```

## 비동기 특성

```jsx
function handleClick() {
    setCount(count + 1);
    console.log(count);  // 아직 이전 값 출력
    // setState는 즉시 반영되지 않고 리렌더링 시 반영
}

// 함수형 업데이트로 해결
function handleClick() {
    setCount(prev => prev + 1);  // O 항상 최신 값 보장
}
```

## 객체/배열 상태 관리

```jsx
// X 직접 수정 (리렌더링 안됨)
const [user, setUser] = useState({ name: '김철수', age: 20 });
user.name = '홍길동';  // 리렌더링 발생 안함

// O 새 객체로 교체
setUser({ ...user, name: '홍길동' });  // 스프레드로 복사 후 수정
```

## useState vs useRef

||useState|useRef|
|---|---|---|
|**값 변경 시 리렌더링**|O|X|
|**렌더링 간 값 유지**|O|O|
|**DOM 접근**|X|O|
|**사용 목적**|UI에 반영되는 값|UI 무관한 값|

## 언제 사용하나?

```
O UI에 표시되는 값 (카운터, 입력값, 토글 등)
O 변경 시 화면을 다시 그려야 하는 값
X UI와 무관한 값 → useRef 사용
X 전역으로 공유해야 하는 값 → Context API, Zustand 등 사용
```

> `useState`는 **값이 바뀔 때마다 화면을 다시 그려야 하는 경우**에 사용하며, UI와 무관한 값 저장은 `useRef`, 전역 상태는 별도 상태관리 라이브러리를 사용합니다.

## 조건문 안에서 호출하면 안 되는 이유

React는 Hook 호출 순서를 기준으로 각 상태를 연결합니다. 따라서 `useState`를 조건문, 반복문, 중첩 함수 안에서 호출하면 렌더링마다 Hook 호출 순서가 달라질 수 있습니다.

```jsx
function Example({ shouldUseState }) {
    if (shouldUseState) {
        const [count, setCount] = useState(0);
    }

    const [name, setName] = useState("");
}
```

`shouldUseState`가 바뀌면 첫 번째 `useState` 호출이 생기거나 사라지고, 이후 Hook의 상태 슬롯이 어긋날 수 있습니다. 그래서 [[Hook의 규칙]]에 따라 Hook은 항상 컴포넌트 최상위에서 같은 순서로 호출해야 합니다.

→ [[왜 useState를 조건문 안에서 사용하면 안 되나요]]
