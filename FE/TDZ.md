let/const로 선언한 변수가 호이스팅은 되지만, 선언문에 도달하기 전까지 접근할 수 없는 구간입니다.

## 왜 존재하나?

- var의 undefined 문제 방지
- 선언 전에 변수를 사용하는 실수 차단
- 더 예측 가능한 코드 작성 유도

## TDZ 동작

```javascript
// --- TDZ 시작 (스코프 진입) ---
console.log(name);  // ReferenceError!
console.log(name);  // ReferenceError!
// --- TDZ 끝 ---
let name = "홍길동";  // 선언 도달 → TDZ 종료
console.log(name);    // "홍길동" (정상)
```

## var vs let 비교

```javascript
// var - 선언 전 접근 가능 (위험)
console.log(a);  // undefined
var a = 10;

// let - TDZ로 보호 (안전)
console.log(b);  // ReferenceError
let b = 10;
```

## TDZ가 적용되는 구간

```javascript
{
  // 블록 시작 = TDZ 시작
  
  // 이 구간에서 name 접근 불가
  
  let name = "홍길동";  // TDZ 끝
  
  console.log(name);  // 접근 가능
}
```

## 실수하기 쉬운 케이스

### 함수 내부에서

```javascript
let value = "외부";

function test() {
  console.log(value);  // ReferenceError!
  let value = "내부";  // 이 선언 때문에 TDZ 발생
}

test();
```

### 기본값 할당에서

```javascript
// 에러: x가 TDZ에 있는데 x를 참조
let x = x + 1;  // ReferenceError

// 앞 변수는 참조 가능
let a = 1;
let b = a + 1;  // 정상
```

### 클래스에서도 동일

```javascript
const instance = new MyClass();  // ReferenceError

class MyClass {}  // 클래스도 TDZ 적용
```

## TDZ 적용 여부

|선언 방식|TDZ|
|---|---|
|**var**|X (undefined로 접근 가능)|
|**let**|O|
|**const**|O|
|**class**|O|
|**함수 선언문**|X|
|**함수 표현식**|let/const 따라감|

## 핵심 정리

```
호이스팅은 된다 + 접근은 안 된다 = TDZ
```
