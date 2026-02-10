React가 리스트의 각 요소를 **고유하게 식별**하기 위해 사용하는 특수한 문자열 속성으로, Virtual DOM 비교(Reconciliation) 시 어떤 요소가 변경·추가·삭제되었는지 판단하는 기준입니다.

## key가 없으면 어떻게 되는가?

```jsx
// key 없이 렌더링
{items.map(item => <li>{item}</li>)}
```

React는 콘솔에 아래 경고를 출력합니다:

```
⚠ Warning: Each child in a list should have a unique "key" prop.
```

key가 없으면 React는 **순서(index)를 기준으로 비교**하므로, index를 key로 사용하는 것과 동일한 문제가 발생합니다.

## key의 동작 원리

### Reconciliation (재조정)

React는 상태가 변경되면 새 Virtual DOM을 만들고, 이전 Virtual DOM과 비교(Diffing)하여 **실제 DOM에 최소한의 변경만 적용**합니다. 이때 리스트 요소는 key를 기준으로 매칭합니다.

```
[이전 VDOM]              [새 VDOM]                [React의 판단]

key="a" → <li>사과       key="c" → <li>포도       key="c": 기존 요소 이동
key="b" → <li>바나나      key="a" → <li>사과       key="a": 기존 요소 이동
key="c" → <li>포도       key="b" → <li>바나나      key="b": 기존 요소 이동

→ 순서만 바뀜, 내부 상태 유지, DOM 노드 재사용
```

### key에 따른 React의 처리

|key 상태|React의 동작|
|---|---|
|**동일한 key 존재**|같은 요소로 인식 → 컴포넌트 재사용, 내부 상태 유지|
|**새로운 key 등장**|새 요소로 인식 → 컴포넌트 마운트 (mount)|
|**기존 key 사라짐**|삭제된 요소로 인식 → 컴포넌트 언마운트 (unmount)|

## key의 규칙

### 1. 형제(sibling) 사이에서 고유해야 한다

```jsx
// ✅ 같은 리스트 내에서 고유
<ul>
  <li key="a">사과</li>
  <li key="b">바나나</li>
</ul>

// ✅ 다른 리스트 간에는 동일해도 상관없음
<ul>
  <li key="a">사과</li>    {/* 이 "a"와 */}
</ul>
<ol>
  <li key="a">딸기</li>    {/* 이 "a"는 서로 다른 리스트이므로 OK */}
</ol>

// ❌ 같은 리스트 내에서 중복
<ul>
  <li key="a">사과</li>
  <li key="a">바나나</li>  {/* 중복 → 예측 불가능한 동작 */}
</ul>
```

### 2. 안정적이어야 한다 (렌더링마다 변하면 안 됨)

```jsx
// ❌ 매 렌더링마다 새 key → 매번 언마운트/마운트 반복
{items.map(item => <li key={Math.random()}>{item}</li>)}

// ❌ 동일한 문제
{items.map(item => <li key={crypto.randomUUID()}>{item}</li>)}

// ✅ 항상 동일한 값
{items.map(item => <li key={item.id}>{item.name}</li>)}
```

### 3. 예측 가능해야 한다

같은 데이터에 대해 항상 같은 key가 부여되어야 합니다.

```jsx
// ✅ 데이터 생성 시점에 ID 부여
const addTodo = (text) => {
  const newTodo = {
    id: crypto.randomUUID(),  // 생성 시 한 번만 부여
    text,
  };
  setTodos(prev => [...prev, newTodo]);
};

// 렌더링 시에는 이미 부여된 ID 사용
{todos.map(todo => <TodoItem key={todo.id} todo={todo} />)}
```

## key의 활용: 컴포넌트 초기화

key가 변경되면 React는 해당 컴포넌트를 **완전히 새로운 요소**로 인식하여 언마운트 후 다시 마운트합니다. 이를 활용하면 컴포넌트 상태를 강제로 초기화할 수 있습니다.

```jsx
function App() {
  const [selectedUserId, setSelectedUserId] = useState(1);

  return (
    // selectedUserId가 바뀌면 ProfileForm이 완전히 새로 마운트됨
    // → 내부 상태(input 값 등)가 자동으로 초기화
    <ProfileForm key={selectedUserId} userId={selectedUserId} />
  );
}

function ProfileForm({ userId }) {
  const [name, setName] = useState('');  // key 변경 시 '' 으로 초기화됨

  return <input value={name} onChange={e => setName(e.target.value)} />;
}
```

```
userId=1 선택 → key=1 → ProfileForm 마운트 (name='')
사용자가 "홍길동" 입력 → name='홍길동'
userId=2 선택 → key=2 → 기존 ProfileForm 언마운트 → 새 ProfileForm 마운트 (name='')
                         ✅ 이전 사용자의 입력값이 깔끔하게 초기화됨
```

## 정리

|항목|설명|
|---|---|
|**역할**|리스트 요소의 고유 식별자, Reconciliation의 매칭 기준|
|**적용 범위**|형제 요소 사이에서만 고유하면 됨|
|**권장 값**|서버 ID, DB PK, 생성 시점의 UUID|
|**피해야 할 값**|index (리스트 변경 시), Math.random() (매번 변경)|
|**활용**|key 변경으로 컴포넌트 상태 강제 초기화 가능|

> **실무 팁**: key는 React의 성능 최적화와 정확한 상태 관리를 위한 핵심 메커니즘입니다. 단순히 경고를 없애기 위해 index를 넣는 것이 아니라, **데이터와 1:1로 매핑되는 안정적인 고유 값**을 사용하는 습관을 들이는 것이 중요합니다.