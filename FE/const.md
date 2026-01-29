ES6에서 도입된 상수 선언 키워드입니다. 블록 스코프를 가지며, 한 번 할당하면 재할당이 불가능합니다.

## 특징 요약

|항목|const|
|---|---|
|스코프|블록 스코프|
|재선언|불가|
|재할당|불가|
|호이스팅|O (TDZ 적용)|
|전역 객체 등록|X|
|선언 시 초기화|필수|

## 재할당 불가

```javascript
const name = "홍길동";
name = "김철수";  // TypeError: Assignment to constant variable

const count = 10;
count++;  // TypeError
```

## 선언 시 초기화 필수

```javascript
const name;  // SyntaxError: Missing initializer
name = "홍길동";

// 반드시 선언과 동시에 값 할당
const name = "홍길동";  // OK
```

## 주의: 객체/배열 내부는 변경 가능

```javascript
// 객체
const user = { name: "홍길동" };
user.name = "김철수";  // 가능!
user.age = 20;         // 가능!
user = {};             // TypeError (재할당 불가)

// 배열
const arr = [1, 2, 3];
arr.push(4);     // 가능! [1, 2, 3, 4]
arr[0] = 100;    // 가능! [100, 2, 3, 4]
arr = [5, 6];    // TypeError (재할당 불가)
```

- const는 "변수 바인딩"이 상수
- 참조하는 객체의 내용은 변경 가능

## 완전한 불변 객체 만들기

```javascript
const user = Object.freeze({ name: "홍길동" });
user.name = "김철수";  // 무시됨 (strict mode에서는 에러)
console.log(user.name);  // "홍길동"

// 중첩 객체는 얕은 동결
const data = Object.freeze({ 
  user: { name: "홍길동" } 
});
data.user.name = "김철수";  // 변경됨! (내부 객체는 동결 안 됨)
```

## TDZ 적용

```javascript
console.log(API_URL);  // ReferenceError (TDZ)
const API_URL = "https://api.example.com";
```

## 언제 사용하나?

```javascript
// 상수값
const PI = 3.14159;
const MAX_SIZE = 100;

// 설정값
const API_URL = "https://api.example.com";
const CONFIG = { timeout: 5000 };

// 참조가 변하지 않는 객체/배열
const user = { name: "홍길동" };
const items = [1, 2, 3];

// 함수
const handleClick = () => { ... };
const calculateTotal = (a, b) => a + b;
```

## 실무 권장

```javascript
// 1순위: const (기본으로 사용)
const name = "홍길동";
const users = [];
const fetchData = async () => { ... };

// 2순위: let (재할당 필요할 때만)
let count = 0;
let isLoading = true;
```

## const vs let 선택

|상황|선택|
|---|---|
|원시값이 변하지 않음|const|
|객체/배열 (내용만 변경)|const|
|값 자체를 재할당해야 함|let|
|루프 카운터|let|
