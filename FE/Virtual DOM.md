실제 [[DOM]]을 직접 조작하는 대신 **메모리에 가상의 DOM 트리를 유지**하여 변경사항을 효율적으로 반영하는 기술입니다.

## 왜 필요한가?

```
실제 DOM 조작은 비용이 크다

DOM 변경
→ 레이아웃 재계산 (Reflow)
→ 화면 다시 그리기 (Repaint)
→ 잦은 변경 시 성능 저하
```

## 동작 방식

```
1. 상태 변경 발생
2. Virtual DOM에 새로운 트리 생성
3. 이전 Virtual DOM과 비교 (Diffing)
4. 변경된 부분만 실제 DOM에 반영 (Reconciliation)
```

## Diffing 과정

```
[이전 Virtual DOM]     [새 Virtual DOM]
<ul>                   <ul>
  <li>A</li>             <li>A</li>
  <li>B</li>             <li>B</li>
  <li>C</li>             <li>C</li>
</ul>                    <li>D</li>  ← 추가됨
                       </ul>

→ D만 실제 DOM에 추가 O
→ A, B, C는 건드리지 않음
```

## 실제 DOM vs Virtual DOM

||실제 DOM|Virtual DOM|
|---|---|---|
|**저장 위치**|브라우저|메모리|
|**조작 비용**|높음|낮음|
|**업데이트**|즉시 반영|배치 처리 후 반영|
|**직접 접근**|O|X|

## React에서의 Virtual DOM

```jsx
function Counter() {
    const [count, setCount] = useState(0);

    return (
        <div>
            <p>{count}</p>           ← count만 변경
            <button onClick={() => setCount(count + 1)}>
                +1
            </button>
        </div>
    );
}

// setCount 호출 시
// 1. 새 Virtual DOM 생성
// 2. 이전과 비교 → <p>만 변경됨
// 3. 실제 DOM의 <p>만 업데이트 O
// 4. <div>, <button>은 그대로
```

## Key의 역할

```jsx
// key 없으면 Diffing 비효율
{items.map(item => <li>{item}</li>)}  // X

// key 있으면 정확한 Diffing 가능
{items.map(item => <li key={item.id}>{item}</li>)}  // O
→ key로 어떤 요소가 변경/추가/삭제됐는지 정확히 파악
```

## Virtual DOM이 항상 빠른가?

```
X 항상 빠른 건 아님

단순한 변경: 실제 DOM 직접 조작이 더 빠를 수 있음
복잡한 UI:   Virtual DOM의 배치 처리가 효율적

→ Virtual DOM의 장점은 "충분히 빠르면서 개발 편의성 제공"
```

> Virtual DOM은 성능보다 **개발 편의성**에 더 큰 의미가 있으며, 직접 DOM을 조작하지 않고 상태(state) 중심으로 UI를 선언적으로 작성할 수 있게 해줍니다.