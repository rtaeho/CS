---
title: "props drilling"
tags: [React, 상태관리]
status: published
---

상위 컴포넌트의 데이터를 하위 컴포넌트에 전달하기 위해 **중간 컴포넌트들이 불필요하게 props를 전달하는 현상**입니다.

## 발생 상황

```
A (데이터 보유)
└── B (props 전달만 함, 사용 안 함)
    └── C (props 전달만 함, 사용 안 함)
        └── D (실제로 데이터 사용) ← 여기까지 전달해야 함
```

## 코드 예시

```jsx
// Props Drilling 발생
function A() {
    const user = { name: "김철수" };
    return <B user={user} />;
}

function B({ user }) {  // 사용 안 하지만 전달
    return <C user={user} />;
}

function C({ user }) {  // 사용 안 하지만 전달
    return <D user={user} />;
}

function D({ user }) {  // 실제 사용
    return <div>{user.name}</div>;
}
```

## 문제점

|문제|설명|
|---|---|
|**코드 복잡도 증가**|중간 컴포넌트마다 불필요한 props 추가|
|**유지보수 어려움**|props 변경 시 모든 중간 컴포넌트 수정 필요|
|**가독성 저하**|데이터 흐름 파악이 어려움|
|**불필요한 리렌더링**|중간 컴포넌트도 props 변경 시 리렌더링|

## 해결 방법

### 1. [[Context API]]

```jsx
const UserContext = createContext();

function A() {
    return (
        <UserContext.Provider value={{ name: "김철수" }}>
            <B />
        </UserContext.Provider>
    );
}

function D() {
    const user = useContext(UserContext);  // 바로 접근 O
    return <div>{user.name}</div>;
}
```

### 2. 전역 상태관리 ([[Redux]], [[Zustand]] 등)

```jsx
// Zustand 예시
const useStore = create((set) => ({
    user: { name: "김철수" }
}));

function D() {
    const user = useStore((state) => state.user);  // 바로 접근 O
    return <div>{user.name}</div>;
}
```

## 해결 방법 비교

| 방법              | 장점                 | 단점             |
| --------------- | ------------------ | -------------- |
| **Context API** | 별도 라이브러리 불필요       | 리렌더링 최적화 어려움   |
| **Redux**       | 강력한 상태관리, DevTools | 보일러플레이트 많음     |
| **Zustand**     | 간단한 API, 가벼움       | Redux보다 생태계 작음 |
|                 |                    |                |

> Props Drilling 자체가 무조건 나쁜 것은 아니며, **depth가 3~4 이상** 깊어질 때 해결 방법을 고려하는 것이 좋습니다.