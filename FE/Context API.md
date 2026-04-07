[[리액트]]에서 **컴포넌트 트리 전체에 데이터를 공유**할 수 있게 해주는 내장 상태 관리 API로, Props Drilling 없이 전역 데이터를 전달할 수 있습니다.

## 핵심 구성 요소

|요소|역할|
|---|---|
|`createContext()`|Context 생성|
|`Provider`|데이터 제공 (상위 컴포넌트)|
|`useContext()`|데이터 소비 (하위 컴포넌트)|

## 기본 사용법

```jsx
// 1. Context 생성
const UserContext = createContext(null);

// 2. Provider로 데이터 제공
function App() {
    const [user, setUser] = useState({ name: "김철수" });
    return (
        <UserContext.Provider value={{ user, setUser }}>
            <A />
        </UserContext.Provider>
    );
}

// 3. 하위 어디서든 바로 접근
function D() {
    const { user } = useContext(UserContext);
    return <div>{user.name}</div>;  // Props 없이 접근 ✅
}
```

## Props Drilling과 비교

```
[Props Drilling]
App → A(user) → B(user) → C(user) → D(user) 사용

[Context API]
App(Provider)
├── A
│   └── B
│       └── C
│           └── D → useContext로 바로 접근 ✅
```

## 주의점 - 리렌더링

```jsx
// Provider value가 바뀌면 useContext 사용하는 모든 컴포넌트 리렌더링
// 객체를 직접 넣으면 매번 새 객체 생성 → 불필요한 리렌더링 💀
<UserContext.Provider value={{ user, setUser }}>

// useMemo로 최적화
const value = useMemo(() => ({ user, setUser }), [user]);
<UserContext.Provider value={value}>  // ✅
```

## 언제 사용하나?

|적합한 경우|부적합한 경우|
|---|---|
|테마, 언어 설정|자주 바뀌는 데이터|
|로그인 사용자 정보|복잡한 상태 로직|
|Props Drilling 3단계 이상|대규모 앱 전역 상태|

## Context API vs 전역 상태관리

||Context API|[[Redux]] / [[Zustand]]|
|---|---|---|
|**설치**|불필요 (내장)|별도 설치|
|**리렌더링 최적화**|어려움|쉬움|
|**DevTools**|❌|✅|
|**복잡한 상태**|부적합|적합|
|**적합한 규모**|소~중규모|중~대규모|

> Context API는 **자주 변경되지 않는 전역 데이터**(테마, 인증 정보 등)에 적합하며, 복잡하거나 자주 바뀌는 상태는 **Redux, Zustand** 같은 전용 라이브러리가 더 적합합니다.