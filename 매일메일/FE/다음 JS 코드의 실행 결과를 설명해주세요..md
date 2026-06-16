---
title: "다음 JS 코드의 실행 결과를 설명해주세요."
tags: [JavaScript, CallByValue]
status: published
---

```js
function change(a, b, c) {
    a = 'a changed'
    b = { b: 'changed' };
    c.c = 'changed';
}

let a = 'a unchanged';
let b = { b: 'unchanged' };
let c = { c: 'unchanged' };

change(a, b, c);

console.log(a, b, c); // ?
```

**답:** `a unchanged {b: 'unchanged'} {c: 'changed'}`

자바스크립트는 **[[Call By Value]] 방식**으로 매개변수를 전달합니다. 이는 함수 매개변수에 **값의 복사본**이 전달된다는 의미입니다. 이로 인해 다음과 같은 결과가 나타납니다.

### 1. a (문자열)

`a`는 문자열입니다. 문자열 값의 복사본이 파라미터에 전달되므로, 함수 내에서 값이 변경되어도 호출한 곳의 변수에는 영향을 미치지 않습니다.

따라서 호출한 곳의 `a`는 여전히 `'a unchanged'`로 유지됩니다.

### 2. b (객체)

`b`는 객체입니다. 원본 객체의 참조 값(주소)의 복사본이 파라미터에 전달됩니다. `b = { b: 'changed' }`와 같이 객체를 새롭게 할당하면, 해당 복사본이 가리키는 참조 값이 새로운 객체의 참조 값으로 변경됩니다.
이로 인해 함수 내의 복사본 `b`는 `b = { b: 'changed' }`의 참조 값을 가리키게 되지만, 함수 외부의 `b`는 여전히 `{ b: 'unchanged' }`로 유지됩니다.

### 3. c (객체)

`c`는 객체입니다. 원본 객체의 참조 값의 복사본이 파라미터에 전달됩니다. 함수 내부와 외부의 변수가 모두 동일한 참조 값을 가리키고 있으므로, 함수 내부에서 객체의 속성을 변경하면 호출한 곳의 객체에도 영향을 미칩니다.

`c.c = 'changed'`는 c 객체의 속성을 변경한 것이므로, 호출한 곳의 c 객체는 `{ c: 'changed' }`로 변경됩니다.
