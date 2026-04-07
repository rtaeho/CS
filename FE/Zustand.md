[[리액트]]에서 **간단하고 가벼운 전역 상태 관리**를 위한 라이브러리로, [[Redux]]보다 훨씬 적은 보일러플레이트로 상태를 관리할 수 있습니다.

## 핵심 특징

```
- 설정 복잡도 낮음
- 보일러플레이트 최소화
- Provider 불필요
- 리렌더링 최적화 용이
```

## 기본 사용법

```jsx
import { create } from 'zustand';

// Store 생성
const useUserStore = create((set) => ({
    name: '',
    isLogin: false,
    login: (name) => set({ name, isLogin: true }),
    logout: () => set({ name: '', isLogin: false })
}));

// 컴포넌트에서 사용 (Provider 없이 바로 사용 ✅)
function Profile() {
    const { name, logout } = useUserStore();
    return (
        <div>
            <p>{name}</p>
            <button onClick={logout}>로그아웃</button>
        </div>
    );
}
```

## 리렌더링 최적화

```jsx
// 필요한 상태만 구독 → 해당 상태 변경 시에만 리렌더링
function Profile() {
    const name = useUserStore((state) => state.name); // name만 구독
    return <div>{name}</div>;
}

// Context API는 Provider value 전체가 바뀌면 모두 리렌더링 💀
// Zustand는 구독한 상태만 바뀔 때 리렌더링 ✅
```

## Redux vs Zustand

||Redux (Toolkit)|Zustand|
|---|---|---|
|**Provider**|필요|❌ 불필요|
|**보일러플레이트**|많음|적음|
|**학습 난이도**|높음|낮음|
|**DevTools**|✅|✅ (미들웨어)|
|**미들웨어**|Thunk, Saga|내장 미들웨어|
|**적합한 규모**|대규모|소~중규모|

## 비동기 처리

```jsx
const usePostStore = create((set) => ({
    posts: [],
    fetchPosts: async () => {
        const res = await fetch('/api/posts');
        const data = await res.json();
        set({ posts: data });  // 비동기도 간단하게 처리 ✅
    }
}));
```

## 언제 사용하나?

```
✅ 소~중규모 프로젝트
✅ Redux가 너무 복잡하게 느껴질 때
✅ 빠른 개발이 필요할 때
❌ 복잡한 미들웨어 로직이 많은 대규모 프로젝트
```

> Zustand는 **단순함**이 최대 장점으로, 최근 React 생태계에서 Redux를 대체하는 가장 인기 있는 상태 관리 라이브러리로 자리잡고 있습니다.