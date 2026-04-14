JavaScript에서 **모든 객체가 공유하는 속성과 메서드를 정의하는 객체**로, 상속을 구현하는 핵심 메커니즘입니다.

## 핵심 개념

```
모든 JS 객체는 내부적으로 [[Prototype]]을 가짐
→ 속성/메서드를 찾을 때 자신 → 프로토타입 → 프로토타입의 프로토타입 순으로 탐색
→ 이를 프로토타입 체인이라 함
```

## 기본 동작

```javascript
function Person(name) {
    this.name = name;
}

// 프로토타입에 메서드 추가
Person.prototype.sayHello = function() {
    console.log(`안녕, 나는 ${this.name}`);
};

const p1 = new Person('김철수');
const p2 = new Person('홍길동');

p1.sayHello();  // "안녕, 나는 김철수"
p2.sayHello();  // "안녕, 나는 홍길동"

// sayHello는 프로토타입에 하나만 존재
// p1, p2가 공유해서 사용 → 메모리 효율 ✅
```

## 프로토타입 체인

```javascript
p1.sayHello()
→ p1 자신에 sayHello 있나? ❌
→ p1.__proto__ (Person.prototype)에 있나? ✅ → 실행

p1.toString()
→ p1 자신에 없음 ❌
→ Person.prototype에 없음 ❌
→ Object.prototype에 있음 ✅ → 실행
```

```
p1
└── [[Prototype]] → Person.prototype
                    └── [[Prototype]] → Object.prototype
                                        └── [[Prototype]] → null
```

## 인스턴스 속성 vs 프로토타입 속성

```javascript
function Person(name) {
    this.name = name;  // 인스턴스마다 별도 생성
}
Person.prototype.species = '인간';  // 모든 인스턴스가 공유

const p1 = new Person('김철수');
console.log(p1.name);    // "김철수" (인스턴스 속성)
console.log(p1.species); // "인간"   (프로토타입 속성)
```

## ES6 class와의 관계

```javascript
// ES6 class 문법
class Person {
    constructor(name) {
        this.name = name;
    }
    sayHello() {  // 내부적으로 prototype에 추가됨
        console.log(`안녕, 나는 ${this.name}`);
    }
}

// 위 코드는 아래와 동일
function Person(name) {
    this.name = name;
}
Person.prototype.sayHello = function() {
    console.log(`안녕, 나는 ${this.name}`);
};
```

## 프로토타입 상속

```javascript
function Animal(name) {
    this.name = name;
}
Animal.prototype.eat = function() {
    console.log(`${this.name}이 먹는다`);
};

function Dog(name) {
    Animal.call(this, name);  // 부모 생성자 호출
}
Dog.prototype = Object.create(Animal.prototype);  // 상속

const dog = new Dog('멍멍이');
dog.eat();  // "멍멍이이 먹는다" ✅ (Animal 메서드 사용 가능)
```

## 주요 메서드

|메서드|설명|
|---|---|
|`Object.getPrototypeOf(obj)`|프로토타입 조회|
|`Object.create(proto)`|프로토타입 지정하여 객체 생성|
|`obj.hasOwnProperty(key)`|자신의 속성인지 확인|
|`instanceof`|프로토타입 체인에 있는지 확인|

```javascript
console.log(p1 instanceof Person);  // true
console.log(p1 instanceof Object);  // true
console.log(p1.hasOwnProperty('name'));    // true
console.log(p1.hasOwnProperty('sayHello')); // false (프로토타입 속성)
```

> JS의 class 문법은 **프로토타입을 기반으로 한 문법적 설탕(Syntactic Sugar)** 이며, 내부적으로는 여전히 프로토타입 체인으로 동작합니다.