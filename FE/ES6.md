2015년에 발표된 **JavaScript의 6번째 표준 명세(ECMAScript 2015)**로, `let/const`, 화살표 함수, 클래스, Promise, 모듈 등 **현대 JavaScript의 핵심 문법 대부분이 도입된 가장 큰 변화의 버전**입니다.

## 핵심 개념

|항목|내용|
|---|---|
|**정식 명칭**|ECMAScript 2015 (ES2015)|
|**발표**|2015년 6월 (ECMA International)|
|**이전 버전**|ES5 (2009년) — 6년 만의 대규모 업데이트|
|**의미**|현대 JavaScript의 기준점|

```
ES5 (2009) ──── 6년 공백 ──── ES6 (2015) ── ES7 ── ES8 ── ...
                                  │
                          현대 JS의 기준점
                      이후 매년 소규모 업데이트
```

## 주요 변경 사항 요약

|기능|ES5 (이전)|ES6 (이후)|
|---|---|---|
|변수 선언|`var`|`let`, `const`|
|함수|`function`|화살표 함수 `=>`|
|문자열|`'hello ' + name`|템플릿 리터럴 `` `hello ${name}` ``|
|객체지향|프로토타입 직접 조작|`class` 문법|
|비동기|콜백|`Promise`|
|모듈|없음 (CommonJS 등 외부)|`import` / `export`|
|구조분해|수동 추출|구조분해 할당|
|반복|`for`, `for...in`|`for...of`, 이터레이터|
|기본 매개변수|수동 체크|기본값 지원|
|컬렉션|`Object`, `Array`|`Map`, `Set`, `WeakMap`, `WeakSet`|

---

## 주요 문법 상세

### 1. let / const (블록 스코프)

```javascript
// ❌ var — 함수 스코프, 호이스팅 문제
var x = 1;
if (true) {
    var x = 2;  // 같은 x를 덮어씀
}
console.log(x);  // 2 (의도치 않은 변경)

// ✅ let — 블록 스코프, 재할당 가능
let y = 1;
if (true) {
    let y = 2;  // 블록 내부의 별도 y
}
console.log(y);  // 1 (외부 y 유지)

// ✅ const — 블록 스코프, 재할당 불가
const PI = 3.14;
PI = 3.15;  // ❌ TypeError

// 단, 객체의 내부 속성은 변경 가능
const user = { name: "홍길동" };
user.name = "김철수";  // ✅ 가능
user = {};             // ❌ 재할당 불가
```

|구분|var|let|const|
|---|---|---|---|
|**스코프**|함수 스코프|블록 스코프|블록 스코프|
|**재선언**|가능|불가|불가|
|**재할당**|가능|가능|불가|
|**호이스팅**|초기화됨 (undefined)|TDZ (에러)|TDZ (에러)|

```javascript
// 호이스팅 차이
console.log(a);  // undefined (var는 호이스팅 시 undefined 초기화)
var a = 1;

console.log(b);  // ❌ ReferenceError (TDZ — Temporal Dead Zone)
let b = 2;
```

### 2. 화살표 함수

```javascript
// ES5
var add = function(a, b) {
    return a + b;
};

// ES6 — 화살표 함수
const add = (a, b) => a + b;

// 본문이 여러 줄이면 중괄호 + return 필요
const greet = (name) => {
    const message = `안녕하세요 ${name}님`;
    return message;
};

// 매개변수 1개면 괄호 생략 가능
const double = x => x * 2;
```

화살표 함수의 핵심 차이는 **this 바인딩**입니다.

```javascript
// ❌ 일반 함수 — this가 호출 방식에 따라 변함
const obj = {
    name: "홍길동",
    greet: function() {
        setTimeout(function() {
            console.log(this.name);  // undefined (this = window/global)
        }, 100);
    }
};

// ✅ 화살표 함수 — this가 선언된 위치의 this를 그대로 사용
const obj2 = {
    name: "홍길동",
    greet: function() {
        setTimeout(() => {
            console.log(this.name);  // "홍길동" (상위 스코프의 this)
        }, 100);
    }
};
```

### 3. 템플릿 리터럴

```javascript
const name = "홍길동";
const age = 25;

// ES5
var msg = '이름: ' + name + ', 나이: ' + age + '세';

// ES6 — 백틱(`) + ${표현식}
const msg = `이름: ${name}, 나이: ${age}세`;

// 여러 줄 문자열
const html = `
    <div>
        <h1>${name}</h1>
        <p>${age}세</p>
    </div>
`;

// 표현식 삽입 가능
const result = `합계: ${10 + 20}`;  // "합계: 30"
```

### 4. 구조분해 할당 (Destructuring)

```javascript
// 객체 구조분해
const user = { id: 1, name: "홍길동", age: 25 };

// ES5
var id = user.id;
var name = user.name;

// ES6
const { id, name, age } = user;
const { name: userName, age: userAge } = user;  // 변수 이름 변경
const { id, ...rest } = user;  // rest = { name: "홍길동", age: 25 }

// 배열 구조분해
const arr = [1, 2, 3, 4, 5];

const [first, second] = arr;           // first=1, second=2
const [a, , c] = arr;                  // a=1, c=3 (2번째 건너뜀)
const [head, ...tail] = arr;           // head=1, tail=[2,3,4,5]

// 함수 매개변수에서 구조분해
function printUser({ name, age }) {
    console.log(`${name}, ${age}세`);
}
printUser({ name: "홍길동", age: 25 });
```

### 5. 스프레드 / 나머지 연산자 (...)

```javascript
// 스프레드 — 배열/객체를 펼침
const arr1 = [1, 2, 3];
const arr2 = [...arr1, 4, 5];  // [1, 2, 3, 4, 5]

const obj1 = { a: 1, b: 2 };
const obj2 = { ...obj1, c: 3 };  // { a: 1, b: 2, c: 3 }

// 배열 복사
const copy = [...arr1];  // 얕은 복사

// 함수 인자 전달
Math.max(...arr1);  // 3

// 나머지 매개변수 — 여러 인자를 배열로 수집
function sum(...numbers) {
    return numbers.reduce((a, b) => a + b, 0);
}
sum(1, 2, 3, 4);  // 10
```

### 6. 클래스

```javascript
// ES5 — 프로토타입 직접 조작
function Animal(name) {
    this.name = name;
}
Animal.prototype.speak = function() {
    return this.name + ' makes a sound';
};

// ES6 — class 문법 (내부적으로는 여전히 프로토타입)
class Animal {
    constructor(name) {
        this.name = name;
    }

    speak() {
        return `${this.name} makes a sound`;
    }
}

// 상속
class Dog extends Animal {
    constructor(name, breed) {
        super(name);        // 부모 생성자 호출
        this.breed = breed;
    }

    bark() {
        return `${this.name} barks`;
    }
}

const dog = new Dog("바둑이", "진돗개");
dog.speak();  // "바둑이 makes a sound"
dog.bark();   // "바둑이 barks"
```

### 7. Promise

```javascript
// ES5 — 콜백
getData(function(data) {
    getMore(data, function(more) {
        // 콜백 지옥...
    });
});

// ES6 — Promise
getData()
    .then(data => getMore(data))
    .then(more => console.log(more))
    .catch(error => console.error(error));
```

### 8. 모듈 (import / export)

```javascript
// math.js — 내보내기
export const PI = 3.14;
export function add(a, b) { return a + b; }
export default class Calculator { /* ... */ }

// app.js — 가져오기
import Calculator, { PI, add } from './math.js';

console.log(PI);         // 3.14
console.log(add(1, 2));  // 3
```

|구분|Named Export|Default Export|
|---|---|---|
|**개수**|여러 개 가능|파일당 1개|
|**import**|`{ 이름 }`|이름 자유|
|**용도**|유틸 함수, 상수|메인 클래스/함수|

### 9. Map / Set

```javascript
// Map — 키-값 쌍 (키에 모든 타입 가능)
const map = new Map();
map.set("name", "홍길동");
map.set(1, "one");
map.set(true, "yes");
map.get("name");  // "홍길동"
map.size;          // 3

// Set — 중복 없는 값의 집합
const set = new Set([1, 2, 3, 3, 3]);
console.log(set.size);    // 3
console.log([...set]);    // [1, 2, 3]
set.has(2);               // true

// 배열 중복 제거
const unique = [...new Set([1, 1, 2, 2, 3])];  // [1, 2, 3]
```

### 10. Symbol / Iterator / for...of

```javascript
// Symbol — 고유한 식별자
const id = Symbol("id");
const user = { [id]: 123, name: "홍길동" };

// for...of — 이터러블 순회
const arr = [10, 20, 30];
for (const value of arr) {
    console.log(value);  // 10, 20, 30 (값을 순회)
}

// for...in과의 차이
for (const key in arr) {
    console.log(key);    // "0", "1", "2" (키/인덱스를 순회)
}
```

## ES6 이후 주요 추가 기능

|버전|연도|주요 기능|
|---|---|---|
|**ES2016 (ES7)**|2016|`Array.includes()`, `**` 거듭제곱 연산자|
|**ES2017 (ES8)**|2017|`async/await`, `Object.entries()`|
|**ES2018**|2018|객체 스프레드, `Promise.finally()`|
|**ES2020**|2020|Optional Chaining `?.`, Nullish Coalescing `??`|
|**ES2022**|2022|Top-level `await`, private 필드 `#`, `.at()`|

```javascript
// ES2017: async/await
async function fetchUser() {
    const response = await fetch("/api/user");
    return await response.json();
}

// ES2020: Optional Chaining + Nullish Coalescing
const city = user?.address?.city ?? "서울";

// ES2022: private 필드
class Counter {
    #count = 0;       // private
    increment() { this.#count++; }
    get value() { return this.#count; }
}
```