개발 환경에서 잠재적인 문제를 찾아주는 React의 검사 도구입니다. 실제 UI를 렌더링하지 않고, 경고만 출력합니다.

## 사용법

```jsx
import { StrictMode } from 'react';

root.render(
  <StrictMode>
    <App />
  </StrictMode>
);
```

## 왜 필요한가?

- 안전하지 않은 생명주기 메서드 감지
- 레거시 API 사용 경고
- 예상치 못한 부작용(side effect) 발견
- 미래 React 버전과의 호환성 대비

## 주요 검사 항목

|검사|설명|
|---|---|
|**이중 렌더링**|컴포넌트를 두 번 렌더링해서 부작용 감지|
|**이중 Effect 실행**|useEffect를 두 번 실행해서 cleanup 확인|
|**deprecated API 경고**|findDOMNode, 레거시 context 등|
|**ref 콜백 검사**|ref 콜백의 cleanup 함수 확인|

## 이중 렌더링이 중요한 이유

```jsx
function Counter() {
  const [count, setCount] = useState(0);
  
  // 잘못된 예: 렌더링 중 외부 상태 변경
  let external = 0;
  external++;  // StrictMode에서 두 번 실행되어 문제 발견
  
  console.log('렌더링');  // 개발 모드에서 두 번 출력됨
  
  return <div>{count}</div>;
}
```

## useEffect 이중 실행

```jsx
useEffect(() => {
  const connection = createConnection();
  connection.connect();
  
  // cleanup이 없으면 StrictMode에서 연결이 두 번 생김
  return () => connection.disconnect();  // cleanup 필수!
}, []);
```

- mount → unmount → mount 순서로 실행
- cleanup 함수가 제대로 작동하는지 확인

## 특징

- **개발 모드에서만** 동작
- 프로덕션 빌드에서는 아무 영향 없음
- 경고는 콘솔에 출력
- 자식 컴포넌트 전체에 적용

## 흔한 오해

```
"useEffect가 두 번 실행돼요!"
→ StrictMode 때문. 정상 동작.
→ 프로덕션에서는 한 번만 실행됨.
→ cleanup을 제대로 작성했는지 확인하라는 신호.
```
