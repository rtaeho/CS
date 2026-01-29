ES5 이전부터 사용된 변수 선언 키워드입니다. 함수 스코프를 가지며, 현재는 let/const에 밀려 거의 사용하지 않습니다.

## 특징 요약

|항목|var|
|---|---|
|스코프|함수 스코프|
|재선언|가능|
|재할당|가능|
|호이스팅|O (undefined로 초기화)|
|전역 객체 등록|O (window)|
|TDZ|없음|

## 함수 스코프

```javascript
function test() {
  if (true) {
    var x = 10;
  }
  console.log(x);  // 10 (블록 밖에서도 접근 가능)
}

// 블록을 무시함
for (var i = 0; i < 3; i++) {}
console.log(i);  // 3 (루프 밖에서도 접근)
```

## 재선언 가능

```javascript
var name = "홍길동";
var name = "김철수";  // 에러 없음 (위험!)
var name = "박영희";  // 또 가능

// 실수로 같은 이름 써도 모름
```

## 호이스팅 (TDZ 없음)

```javascript
console.log(a);  // undefined (에러 아님)
var a = 10;
console.log(a);  // 10

// 내부적으로 이렇게 동작
var a = undefined;
console.log(a);
a = 10;
console.log(a);
```

## 전역 객체 등록

```javascript
var globalVar = "hello";
console.log(window.globalVar);  // "hello"

// 의도치 않게 전역 오염 가능
```

## var의 문제점

### 1. 클로저 문제

```javascript
for (var i = 0; i < 3; i++) {
  setTimeout(() => {
    console.log(i);  // 3, 3, 3 (의도: 0, 1, 2)
  }, 100);
}

// let으로 해결
for (let i = 0; i < 3; i++) {
  setTimeout(() => {
    console.log(i);  // 0, 1, 2
  }, 100);
}
```

### 2. 조용한 버그

```javascript
var count = 10;

function calculate() {
  console.log(count);  // undefined (의도: 10)
  var count = 20;
}
```

### 3. 의도치 않은 덮어쓰기

```javascript
var user = "홍길동";
// ... 수백 줄의 코드 ...
var user = "김철수";  // 실수로 재선언 (에러 없음)
```

## 언제 보게 되나?

- 레거시 코드 유지보수
- 오래된 라이브러리
- ES5 이하 환경 지원 필요 시

## 결론

```javascript
// ❌ 사용하지 말 것
var name = "홍길동";

// ✅ 대신 사용
const name = "홍길동";
let count = 0;
```
