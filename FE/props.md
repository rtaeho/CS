**부모 컴포넌트가 자식에게 전달하는 데이터**입니다.

---

## 예시

```jsx
// 부모 컴포넌트
function Parent() {
    return <Child name="철수" age={25} />;
}

// 자식 컴포넌트
function Child(props) {
    return <div>{props.name}은 {props.age}살</div>;
}
```

`name`, `age`가 props입니다.

---

## 특징

|특징|설명|
|---|---|
|읽기 전용|자식이 수정 불가|
|단방향|부모 → 자식으로만 전달|
|외부에서 주입|자식이 직접 만들지 않음|

```jsx
function Child(props) {
    props.name = "영희";  // ❌ 에러! 수정 불가
}
```

---

## Props vs State

```jsx
function Parent() {
    const [count, setCount] = useState(0);  // state: 내가 관리
    
    return <Child count={count} />;  // props: 자식에게 전달
}

function Child({ count }) {
    // count는 props: 받기만 함, 수정 못 함
}
```

||Props|State|
|---|---|---|
|소유자|부모|자기 자신|
|수정|불가|가능|
|역할|데이터 전달|데이터 관리|

---

## 어원

**Properties**의 줄임말입니다. HTML 속성처럼 컴포넌트에 값을 전달합니다.

```jsx
<img src="photo.jpg" />      // HTML 속성
<Child name="철수" />        // React props
```