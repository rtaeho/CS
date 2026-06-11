React에서 **렌더링과 무관하게 값을 저장**하거나, **DOM 요소에 직접 접근**할 때 사용하는 Hook입니다.

## 핵심 특징

```
1. 값이 변경되어도 리렌더링 발생 안함
2. 렌더링 간에 값이 유지됨
3. DOM 요소에 직접 접근 가능
```

## [[useState]] vs useRef

||useState|useRef|
|---|---|---|
|**값 변경 시 리렌더링**|O|X|
|**렌더링 간 값 유지**|O|O|
|**DOM 접근**|X|O|

## 사용 1 - DOM 직접 접근

```jsx
function InputFocus() {
    const inputRef = useRef(null);

    const handleClick = () => {
        inputRef.current.focus();  // DOM에 직접 접근 O
    };

    return (
        <>
            <input ref={inputRef} />
            <button onClick={handleClick}>포커스</button>
        </>
    );
}
```

## 사용 2 - 렌더링 없이 값 저장

```jsx
function Timer() {
    const timerRef = useRef(null);  // 타이머 ID 저장

    const start = () => {
        timerRef.current = setInterval(() => {
            console.log('tick');
        }, 1000);
    };

    const stop = () => {
        clearInterval(timerRef.current);  // 리렌더링 없이 접근 O
    };

    return (
        <>
            <button onClick={start}>시작</button>
            <button onClick={stop}>정지</button>
        </>
    );
}
```

## 사용 3 - 이전 값 저장

```jsx
function Counter() {
    const [count, setCount] = useState(0);
    const prevCount = useRef(0);

    useEffect(() => {
        prevCount.current = count;  // 이전 값 저장
    }, [count]);

    return (
        <div>
            현재: {count} / 이전: {prevCount.current}
            <button onClick={() => setCount(c => c + 1)}>+1</button>
        </div>
    );
}
```

## 주의사항

```jsx
// X 렌더링 중에 ref 값 읽기/쓰기
function Component() {
    const ref = useRef(0);
    ref.current = 123;  // 렌더링 중 수정 금지
    return <div>{ref.current}</div>;  // 렌더링 중 읽기 금지
}

// O 이벤트 핸들러나 useEffect에서 사용
function Component() {
    const ref = useRef(0);
    useEffect(() => {
        ref.current = 123;  // O
    });
}
```

> `useRef`는 **리렌더링을 유발하지 않아야 하는 값**을 저장할 때 사용하며, DOM 접근이 필요한 경우 `useState` 대신 `useRef`를 선택합니다.