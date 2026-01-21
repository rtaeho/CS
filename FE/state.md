**컴포넌트가 스스로 관리하는 데이터**입니다.

---

## 예시

```jsx
function Counter() {
    const [count, setCount] = useState(0);  // state
    
    return (
        <div>
            <p>{count}</p>
            <button onClick={() => setCount(count + 1)}>
                증가
            </button>
        </div>
    );
}
```

`count`가 state입니다. 버튼 클릭하면 값이 바뀌고 화면이 다시 렌더링됩니다.

---

## 특징

|특징|설명|
|---|---|
|수정 가능|setter로 변경|
|내부에서 관리|자기 자신이 소유|
|변경 시 리렌더링|화면 자동 업데이트|

---

## Props vs State 정리

```jsx
function Parent() {
    const [name, setName] = useState("철수");  // Parent의 state
    
    return <Child name={name} />;  // Child에게는 props
}

function Child({ name }) {
    const [age, setAge] = useState(25);  // Child의 state
    
    return <div>{name}은 {age}살</div>;
}
```

||Props|State|
|---|---|---|
|누가 소유|부모|자기 자신|
|수정|불가|가능|
|용도|데이터 전달|데이터 관리|
|변경 시|부모가 바꿔줘야 함|직접 변경|

---

## 어원

**상태(State)** — 컴포넌트의 현재 상태를 나타냅니다.