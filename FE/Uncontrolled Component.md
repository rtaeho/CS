**DOM이 폼 요소의 값을 직접 관리**하는 방식입니다.

---

## 예시

```jsx
function Form() {
    const inputRef = useRef();
    
    const handleSubmit = () => {
        console.log(inputRef.current.value);  // DOM에서 직접 읽음
    };
    
    return (
        <div>
            <input ref={inputRef} defaultValue="초기값" />
            <button onClick={handleSubmit}>제출</button>
        </div>
    );
}
```

---

## 동작 흐름

```
1. 사용자가 'a' 입력
2. DOM의 input 요소가 값을 저장
3. React는 모름 (리렌더링 없음)
4. 필요할 때 ref로 DOM에서 값을 읽어옴
```

---

## Controlled vs Uncontrolled

||Controlled|Uncontrolled|
|---|---|---|
|값 저장|React state|DOM|
|값 설정|`value`|`defaultValue`|
|값 접근|state 변수|`ref.current.value`|
|리렌더링|입력마다 발생|없음|

---

## 언제 쓰는가

```jsx
// 파일 입력 (Uncontrolled만 가능)
<input type="file" ref={fileRef} />

// 간단한 폼 (굳이 state 필요 없을 때)
<input ref={nameRef} defaultValue="홍길동" />
```

|상황|선택|
|---|---|
|실시간 검증 필요|Controlled|
|입력값 가공 필요|Controlled|
|파일 입력|Uncontrolled|
|간단한 폼|Uncontrolled|

---

## 핵심 차이

```
Controlled: React가 주인 (state → DOM)
Uncontrolled: DOM이 주인 (DOM → ref로 읽음)
```