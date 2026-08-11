---
title: "String Constant Pool"
tags: [Java, 메모리, 문자열]
status: published
---

같은 내용의 문자열 리터럴을 하나의 객체로 공유하기 위해 JVM이 Heap 영역에 따로 마련해둔 저장 공간입니다.

## 리터럴 생성과 생성자 생성의 차이

```java
String first = "hello";              // 리터럴 — Pool에 저장
String second = new String("hello"); // 생성자 — Heap에 새 객체
String third = "hello";              // Pool에 이미 있으므로 재사용

System.out.println(System.identityHashCode(first));  // 498931366
System.out.println(System.identityHashCode(second)); // 2060468723
System.out.println(System.identityHashCode(third));  // 498931366
```

리터럴로 만든 문자열은 Pool에 등록되고, 같은 문자열이 이미 있으면 그 주소를 그대로 참조합니다. 반면 `new String()`은 내용이 같더라도 항상 새로운 객체를 Heap에 만듭니다.

그래서 `first == third`는 `true`지만 `first == second`는 `false`입니다. 내용 비교는 항상 `equals()`를 써야 하는 이유입니다. ([[동일성]]과 [[동등성]] 참고)

## intern()

`intern()`은 Heap에 있는 String 객체를 Pool에 등록하고 Pool의 참조를 돌려줍니다. 이미 같은 문자열이 Pool에 있으면 그 주소를 반환합니다.

```java
String first = "hello";
String second = new String("hello");
String third = second.intern();

System.out.println(System.identityHashCode(first));  // 498931366
System.out.println(System.identityHashCode(third));  // 498931366  ← first와 동일
```

## 왜 필요한가

문자열은 프로그램에서 가장 많이 쓰이는 값입니다. 같은 문자열이 수백 번 등장할 때마다 객체를 새로 만들면 메모리 낭비가 큽니다. Pool은 이를 공유해 메모리를 절약합니다.

이 공유가 안전한 이유는 String이 [[불변 객체]]이기 때문입니다. 여러 참조가 같은 객체를 가리켜도 누구도 그 내용을 바꿀 수 없으므로 서로 영향을 주지 않습니다. 만약 String이 가변이었다면 한쪽에서 값을 바꿨을 때 그 문자열을 공유하던 모든 코드가 영향을 받았을 것입니다.

## 주의사항

- Java 7부터 Pool은 PermGen이 아닌 **Heap** 영역에 있습니다. 따라서 GC 대상이 되며, 크기도 Heap 설정을 따릅니다.
- 컴파일 시점에 결정되는 상수 표현식(`"he" + "llo"`)은 컴파일러가 합쳐서 리터럴로 만들므로 Pool에 들어갑니다. 반면 변수를 더한 결과는 런타임에 새 객체가 되어 Pool에 들어가지 않습니다.
- `new String()`은 굳이 쓸 이유가 거의 없습니다. 불필요하게 객체를 하나 더 만드는 셈입니다.

## 핵심 정리

- 문자열 리터럴은 Pool에서 공유되고, `new String()`은 항상 새 객체를 만듭니다.
- `intern()`으로 Heap의 문자열을 Pool에 등록할 수 있습니다.
- String이 불변이기 때문에 이 공유가 안전하게 성립합니다.

→ [[String 객체는 가변일까요, 불변일까요? 그렇게 생각하신 이유도 함께 설명해 주세요]]
