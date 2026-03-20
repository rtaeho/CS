UI를 독립적이고 재사용 가능한 단위로 쪼갠 것으로, React 애플리케이션을 구성하는 기본 단위입니다.

## 구조

```
App
├── Header
├── Main
│   ├── PostList
│   │   ├── PostItem
│   │   └── PostItem
│   └── Sidebar
└── Footer
```

## 함수형 컴포넌트

```jsx
// 기본 구조
function UserCard({ name, age }) {       // props 받기
    const [likes, setLikes] = useState(0); // 상태 관리

    return (
        <div>
            <h2>{name} ({age})</h2>
            <button onClick={() => setLikes(likes + 1)}>
                좋아요 {likes}
            </button>
        </div>
    );
}

// 사용
<UserCard name="Alice" age={25} />
```

## Props vs State

|항목|Props|State|
|---|---|---|
|정의|부모 → 자식 전달 데이터|컴포넌트 내부 데이터|
|변경|불가 (읽기 전용)|가능 (setState)|
|변경 주체|부모 컴포넌트|자기 자신|
|변경 시|리렌더링 발생|리렌더링 발생|

## 생명주기 (useEffect)

```jsx
function Component() {
    useEffect(() => {
        // 마운트 시 실행
        console.log("컴포넌트 생성");

        return () => {
            // 언마운트 시 실행
            console.log("컴포넌트 제거");
        };
    }, []); // [] = 마운트/언마운트 시에만 실행

    useEffect(() => {
        // count 변경 시마다 실행
        console.log("count 변경됨");
    }, [count]);
}
```

## 컴포넌트 설계 원칙

|원칙|설명|
|---|---|
|단일 책임|컴포넌트 하나는 한 가지 역할만|
|재사용성|Props로 다양한 상황에 대응|
|독립성|다른 컴포넌트에 의존하지 않음|

> React는 **단방향 데이터 흐름**을 따릅니다. Props는 부모 → 자식으로만 전달되며, 자식이 부모 데이터를 바꾸려면 **콜백 함수**를 props로 전달합니다.