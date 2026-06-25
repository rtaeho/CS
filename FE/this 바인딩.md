---
title: "this 바인딩"
tags: [JavaScript, this, 바인딩]
status: published
---

JavaScript에서 `this`가 어떤 객체를 가리킬지 함수 호출 방식에 따라 결정되는 규칙입니다.

## 핵심 특징

- **호출 시점 결정**: 일반 함수의 `this`는 함수가 선언된 위치보다 호출 방식의 영향을 받음
- **메서드 호출**: `obj.method()`처럼 호출하면 `this`는 `obj`
- **생성자 호출**: `new`로 호출하면 `this`는 새로 생성되는 인스턴스
- **명시적 바인딩**: `call`, `apply`, `bind`로 `this`를 직접 지정 가능
- **화살표 함수**: 자체 `this`를 만들지 않고 상위 스코프의 `this`를 캡처

## 일반 함수 호출

```js
function printThis() {
  console.log(this);
}

printThis();
```

브라우저의 non-strict mode에서는 전역 객체인 `window`를 가리킬 수 있습니다. strict mode에서는 `undefined`가 됩니다.

## 메서드 호출

```js
const user = {
  name: "Alice",
  greet() {
    console.log(this.name);
  },
};

user.greet(); // Alice
```

점 앞의 객체가 호출 주체가 되므로 `this`는 `user`를 가리킵니다.

## 생성자와 클래스

```js
class User {
  constructor(name) {
    this.name = name;
  }
}

const user = new User("Alice");
```

`new`로 호출하면 `this`는 새로 만들어지는 인스턴스를 가리킵니다.

## call, apply, bind

```js
function greet() {
  console.log(this.name);
}

const user = { name: "Alice" };

greet.call(user);
const bound = greet.bind(user);
bound();
```

`call`과 `apply`는 즉시 호출하면서 `this`를 지정하고, `bind`는 `this`가 고정된 새 함수를 반환합니다.

## 화살표 함수

```js
const user = {
  name: "Alice",
  greet: () => {
    console.log(this.name);
  },
};
```

화살표 함수는 자체 `this`가 없기 때문에 메서드의 `this`가 필요한 위치에는 적합하지 않을 수 있습니다. 대신 콜백에서 외부 `this`를 유지하고 싶을 때 유용합니다.

## 핵심 정리

`this`는 일반 함수에서는 호출 방식으로 결정되고,
화살표 함수에서는 상위 스코프에서 결정됩니다.

객체 메서드, 이벤트 핸들러, 콜백에서 `this`가 달라질 수 있으므로
필요하면 `bind`나 화살표 함수를 의도적으로 선택해야 합니다.

→ [[상황에 따라 this 바인딩이 어떻게 이뤄지는지 설명해주세요]]
