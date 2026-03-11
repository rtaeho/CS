React 18에서 도입된 **렌더링 작업을 중단·재개·우선순위 조정할 수 있는 렌더링 방식**입니다.

## 기존 렌더링 vs 동시성 모드

```
기존 렌더링 (동기)
→ 한번 시작하면 끝날 때까지 멈출 수 없음
→ 렌더링 중 사용자 입력 → 반응 없음 (버벅임)

시간 →
[------렌더링 중 (중단 불가)------] [사용자 입력 처리]

동시성 모드 (비동기)
→ 렌더링을 잘게 쪼개서 중단/재개 가능
→ 중요한 작업(사용자 입력) 먼저 처리

시간 →
[렌더링] [사용자 입력] [렌더링 재개] [렌더링 완료]
```

## 핵심 기능

### 1. startTransition - 우선순위 낮추기

```jsx
import { startTransition, useState } from 'react';

function SearchPage() {
    const [input, setInput] = useState('');
    const [results, setResults] = useState([]);

    const handleChange = (e) => {
        // 긴급 업데이트 (높은 우선순위) - 입력값 즉시 반영
        setInput(e.target.value);

        // 급하지 않은 업데이트 (낮은 우선순위) - 나중에 처리
        startTransition(() => {
            setResults(searchItems(e.target.value));  // 무거운 작업
        });
    };

    return (
        <>
            <input value={input} onChange={handleChange} />
            <ResultList results={results} />
        </>
    );
}
```

### 2. useTransition - 로딩 상태 관리

```jsx
import { useTransition } from 'react';

function TabContainer() {
    const [isPending, startTransition] = useTransition();
    const [tab, setTab] = useState('home');

    const handleTabChange = (nextTab) => {
        startTransition(() => {
            setTab(nextTab);  // 무거운 탭 전환 → 낮은 우선순위
        });
    };

    return (
        <>
            <TabButton onClick={() => handleTabChange('posts')}>Posts</TabButton>

            {/* 전환 중 로딩 표시 */}
            {isPending ? <Spinner /> : <TabContent tab={tab} />}
        </>
    );
}
```

### 3. useDeferredValue - 값 업데이트 지연

```jsx
import { useDeferredValue } from 'react';

function SearchResults({ query }) {
    // query가 빠르게 바뀌어도 렌더링은 여유있게
    const deferredQuery = useDeferredValue(query);

    return (
        <>
            {/* 입력값은 즉시 반영 */}
            <p>검색어: {query}</p>

            {/* 결과는 여유있게 렌더링 */}
            <HeavyResultList query={deferredQuery} />
        </>
    );
}
```

### 4. Suspense - 로딩 선언적 처리

```jsx
function App() {
    return (
        <Suspense fallback={<Spinner />}>
            {/* 데이터 로딩 중이면 Spinner 표시 */}
            <UserProfile />
        </Suspense>
    );
}
```

## 우선순위 개념

```
높은 우선순위 (긴급)     낮은 우선순위 (여유)
─────────────────        ─────────────────
사용자 입력              startTransition 내부 상태
클릭 이벤트             useDeferredValue
포커스                  데이터 패칭 결과 반영
```

## React 18 활성화 방법

```jsx
// React 17 이하 (동시성 모드 X)
ReactDOM.render(<App />, document.getElementById('root'));

// React 18 (동시성 모드 O)
ReactDOM.createRoot(document.getElementById('root'))
        .render(<App />);
```

## 언제 활용하나?

|상황|해결책|
|---|---|
|검색어 입력 시 결과 렌더링 버벅임|`startTransition`|
|탭 전환 시 느린 렌더링|`useTransition`|
|빠르게 바뀌는 값 기반 무거운 렌더링|`useDeferredValue`|
|비동기 데이터 로딩 UI|`Suspense`|

> React 동시성 모드의 핵심은 **"모든 렌더링이 동등하지 않다"** 는 것입니다. 사용자 입력처럼 즉각 반응해야 할 것과, 검색 결과처럼 여유있게 처리해도 될 것을 **우선순위로 구분해 UX를 개선**합니다.