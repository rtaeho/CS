**React가 폼 요소의 값을 state로 관리**하는 방식입니다.

---

## 예시

```jsx
function Form() {
    const [value, setValue] = useState('');
    
    return (
        <input 
            value={value}                          // state가 값을 결정
            onChange={(e) => setValue(e.target.value)}  // 변경 시 state 업데이트
        />
    );
}
```

---

## 동작 흐름

```
1. 사용자가 'a' 입력
2. onChange 호출 → setValue('a')
3. state가 'a'로 변경
4. 리렌더링 → input의 value가 'a'로 표시
```

**React state가 "진짜 값"**이고, input은 그걸 보여주기만 합니다.

---

## Uncontrolled Component (반대 개념)

```jsx
function Form() {
    const inputRef = useRef();
    
    const handleSubmit = () => {
        console.log(inputRef.current.value);  // DOM에서 직접 읽음
    };
    
    return <input ref={inputRef} />;
}
```

**DOM이 값을 관리**합니다. React는 모릅니다.

---

## 비교

||Controlled|Uncontrolled|
|---|---|---|
|값 관리|React state|DOM|
|값 접근|state 변수|ref로 DOM 접근|
|실시간 검증|쉬움|어려움|
|코드량|많음|적음|

---

## 왜 Controlled를 쓰는가

```jsx
// 실시간 검증 가능
const [email, setEmail] = useState('');
const isValid = email.includes('@');

// 입력값 가공 가능
const handleChange = (e) => {
    setValue(e.target.value.toUpperCase());  // 자동 대문자
};
```

React가 값을 알고 있어서 **제어가 쉽습니다.**