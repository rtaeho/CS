---
title: "Redux"
tags: [상태관리, React]
status: published
---

[[리액트]] 애플리케이션에서 **전역 상태를 예측 가능하게 관리**하기 위한 상태 관리 라이브러리입니다.

## 핵심 원칙

```
1. 단일 스토어 (Single Source of Truth)
   → 모든 상태를 하나의 Store에서 관리

2. 읽기 전용 상태 (State is Read-Only)
   → Action을 통해서만 상태 변경 가능

3. 순수 함수 (Pure Reducers)
   → Reducer는 순수 함수로 상태 변경
```

## 구성 요소

|요소|역할|
|---|---|
|**Store**|전역 상태 저장소|
|**Action**|상태 변경 요청 객체|
|**Reducer**|Action을 받아 새 상태 반환하는 순수 함수|
|**Dispatch**|Action을 Store에 전달|
|**Selector**|Store에서 상태 조회|

## 데이터 흐름

```
컴포넌트 → dispatch(Action)
              ↓
           Reducer (현재 상태 + Action → 새 상태)
              ↓
           Store 업데이트
              ↓
           컴포넌트 리렌더링
```

## 코드 예시 (Redux Toolkit)

```jsx
import { createSlice, configureStore } from '@reduxjs/toolkit';

// Slice (Action + Reducer 통합)
const userSlice = createSlice({
    name: 'user',
    initialState: { name: '', isLogin: false },
    reducers: {
        login: (state, action) => {
            state.name = action.payload;
            state.isLogin = true;
        },
        logout: (state) => {
            state.name = '';
            state.isLogin = false;
        }
    }
});

// Store 생성
const store = configureStore({
    reducer: { user: userSlice.reducer }
});

// 컴포넌트에서 사용
function Profile() {
    const user = useSelector((state) => state.user);
    const dispatch = useDispatch();

    return (
        <div>
            <p>{user.name}</p>
            <button onClick={() => dispatch(userSlice.actions.logout())}>
                로그아웃
            </button>
        </div>
    );
}
```

## Redux vs [[Context API]] vs [[Zustand]]

||Context API|Redux|Zustand|
|---|---|---|---|
|**설치**|불필요|필요|필요|
|**보일러플레이트**|적음|많음|적음|
|**리렌더링 최적화**|어려움|쉬움|쉬움|
|**DevTools**|X|O|O|
|**학습 난이도**|낮음|높음|낮음|
|**적합한 규모**|소규모|대규모|소~중규모|

## 장단점

|장점|단점|
|---|---|
|예측 가능한 상태 관리|보일러플레이트 코드 많음|
|강력한 DevTools|학습 곡선 높음|
|미들웨어 지원 (Redux Thunk, Saga)|소규모엔 과함|
|대규모 앱에 적합|설정 복잡|

> 현재는 Redux의 복잡성을 줄인 **Redux Toolkit**이 공식 권장 방식이며, 소~중규모 프로젝트에서는 더 간단한 **Zustand**가 많이 사용되는 추세입니다.