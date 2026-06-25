---
title: "상황에 따라 this 바인딩이 어떻게 이뤄지는지 설명해주세요"
tags: [매일메일, Frontend]
status: published
---

JavaScript에서 [[this 바인딩]]은 함수가 호출되는 방식에 따라 달라집니다.

## 전역 호출

전역에서 함수가 호출되면 `this`는 전역 객체를 참조합니다. 브라우저 환경에서는 `window` 객체를, Node.js 환경에서는 `global` 객체를 가리킬 수 있습니다. strict mode에서는 `undefined`가 됩니다.

```js
function globalFunc() {
  console.log(this);
}

globalFunc();
```

## 메서드 호출

객체의 메서드로 호출된 함수에서는 `this`가 해당 객체를 참조합니다.

```js
const obj = {
  name: "Alice",
  greet: function () {
    console.log(this.name);
  },
};

obj.greet(); // "Alice"
```

## 생성자 함수와 클래스

생성자 함수나 클래스에서 `this`는 새로 생성되는 객체, 즉 인스턴스를 참조합니다.

```js
function Person(name) {
  this.name = name;
}

const person = new Person("Alice");
console.log(person.name); // "Alice"
```

## 명시적 바인딩

`call()`, `apply()`, `bind()` 메서드를 사용하면 `this`를 명시적으로 설정할 수 있습니다.

```js
function greet() {
  console.log(this.name);
}

const user = { name: "Alice" };
greet.call(user); // "Alice"
```

## 화살표 함수

화살표 함수는 상위 스코프의 `this`를 상속받습니다. 자체적인 `this`를 가지지 않으므로 사용 위치에 따라 `this`가 결정됩니다.

```js
const obj = {
  name: "Alice",
  greet: () => console.log(this.name),
};

obj.greet(); // undefined
```

## DOM 이벤트 핸들러

DOM 요소의 이벤트 핸들러에서 `this`는 기본적으로 이벤트를 발생시킨 요소를 참조합니다. 하지만 화살표 함수를 사용하면 상위 스코프의 `this`를 참조합니다.

```js
button.addEventListener("click", function () {
  console.log(this); // 클릭된 button 요소
});
```

## 추가 학습 자료

- [MDN - this](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Operators/this)
- [F-Lab - 자바스크립트의 this 바인딩 이해하기](https://f-lab.kr/insight/understanding-javascript-this-binding-20240525)
