ES6에서 도입된 변수 선언 키워드입니다. 블록 스코프를 가지며, 재할당이 필요한 변수에 사용합니다.

## 특징 요약

|항목|let|
|---|---|
|스코프|블록 스코프|
|재선언|불가|
|재할당|가능|
|호이스팅|O (TDZ 적용)|
|전역 객체 등록|X|

## 블록 스코프

```javascript
if (true) {
  let x = 10;
  console.log(x);  // 10
}
console.log(x);  // ReferenceError

// for문에서도 블록 안에서만 유효
for (let i = 0; i < 3; i++) {
  console.log(i);  // 0, 1, 2
}
console.log(i);  // ReferenceError
```

## 재선언 불가

```javascript
let name = "홍길동";
let name = "김철수";  // SyntaxError: 이미 선언됨

// 다른 블록에서는 가능
{
  let name = "홍길동";
}
{
  let name = "김철수";  // 다른 블록이라 OK
}
```

## 재할당 가능

```javascript
let count = 0;
count = 1;  // 가능
count = 2;  // 가능

let user = { name: "홍길동" };
user = { name: "김철수" };  // 가능
```

## TDZ 적용

```javascript
console.log(name);  // ReferenceError (TDZ)
let name = "홍길동";
console.log(name);  // "홍길동"
```

## var와 비교 - 클로저 문제 해결

```javascript
// var - 문제 발생
for (var i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 100);
}
// 출력: 3, 3, 3

// let - 문제 해결
for (let i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 100);
}
// 출력: 0, 1, 2
```

- let은 반복마다 새로운 바인딩 생성
- 각 클로저가 해당 시점의 값을 캡처

## 언제 사용하나?

```javascript
// 값이 변해야 할 때
let count = 0;
count++;

let total = 0;
for (let i = 1; i <= 10; i++) {
  total += i;
}

// 조건에 따라 값이 달라질 때
let result;
if (condition) {
  result = "A";
} else {
  result = "B";
}
```

## const와 선택 기준

```javascript
// 기본은 const
const API_URL = "https://api.example.com";
const user = { name: "홍길동" };

// 재할당 필요할 때만 let
let count = 0;
let isLoading = true;
```