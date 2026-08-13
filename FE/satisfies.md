---
title: "satisfies"
tags: [TypeScript, 타입추론, 타입시스템]
status: published
---

TypeScript 4.9에 도입된 연산자로, 값의 타입 추론 결과를 유지하면서 해당 값이 특정 타입 조건을 만족하는지 검사할 때 사용합니다.

## 핵심 특징

- **타입 검사만 수행**: `as`([[타입 단언]])와 달리 값의 타입을 강제로 바꾸지 않고, 지정한 타입을 만족하는지만 검사합니다.
- **추론된 타입을 유지**: 변수 타입을 명시적으로 선언하는 것과 달리, 각 속성의 더 구체적인 타입이 그대로 유지됩니다.
- **유니온 타입에 유용**: 객체의 각 속성이 유니온 타입 중 어떤 타입인지 좁혀서 추론할 수 있습니다.

## 코드 예시

```ts
type Color = "red" | "green" | "blue";
type RGB = [red: number, green: number, blue: number];

const palette: Record<Color, string | RGB> = {
    red: [255, 0, 0],
    green: "#00ff00",
    blue: [0, 0, 255]
};

// ⚠️ 오류 발생
const greenNormalized = palette.green.toUpperCase();
```

위 코드에서 `palette.green`의 타입은 `string | RGB`로 추론되기 때문에 `.toUpperCase()` 호출 시 타입 에러가 발생합니다.

```ts
const palette = {
    red: [255, 0, 0],
    green: "#00ff00",
    blue: [0, 0, 255]
} satisfies Record<Color, string | RGB>;

// ✅ 정상 동작
const greenNormalized = palette.green.toUpperCase();
```

`satisfies`를 사용하면 `palette`가 `Record<Color, string | RGB>` 조건을 만족하는지 검사하면서도, `palette.green`의 타입은 `string`으로 그대로 추론되어 `.toUpperCase()`를 정상적으로 호출할 수 있습니다.

## 타입 애너테이션 · 타입 단언과의 비교

| 항목 | 타입 애너테이션(`: T`) | [[타입 단언]](`as T`) | `satisfies T` |
|---|---|---|---|
| 타입 검사 | 수행함 | 수행하지 않음 | 수행함 |
| 결과 타입 | 선언한 타입으로 넓어짐 | 단언한 타입으로 강제됨 | 원래 추론된 구체적인 타입 유지 |
| 런타임 안전성 | 안전 | 개발자 책임 | 안전 |

## 언제 사용하는가

- 유니온 타입을 다루면서 각 속성의 구체적인 타입을 그대로 활용하고 싶을 때
- 객체 리터럴이 특정 타입 조건을 만족해야 하면서, 동시에 정의하지 않은 추가 필드가 없는지도 검사하고 싶을 때

## 핵심 정리

`satisfies`는 타입을 강제로 바꾸지 않고 조건 충족 여부만 검사하기 때문에, 의도보다 더 넓은 타입으로 추론되는 것을 방지하면서도 각 속성의 구체적인 타입 정보를 잃지 않을 수 있습니다.

→ [[타입스크립트 satisfies 키워드에 대해 설명해주세요]]
