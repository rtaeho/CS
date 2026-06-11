---
title: "상속 vs 합성"
tags: [객체지향, SOLID, 설계]
status: published
---

코드를 재사용하는 두 가지 방법 — **상속(is-a)** 과 **합성(has-a)** 의 차이입니다.

## 상속 (Inheritance)

부모 클래스를 `extends`해 코드를 물려받는 방식.

```java
class Vehicle {
    protected int speed;
    void accelerate() { speed += 10; }
}

class Car extends Vehicle {
    private int doors;
    // accelerate() 그대로 상속
    void honk() { System.out.println("빵빵"); }
}
```

**Car is-a Vehicle** → 관계가 명확할 때 자연스러움.

## 합성 (Composition)

다른 클래스의 인스턴스를 **필드로 포함**해 기능을 재사용하는 방식.

```java
class Engine {
    void start() { System.out.println("부릉"); }
}

class Car {
    private final Engine engine = new Engine();  // has-a

    void startCar() {
        engine.start();    // 위임(delegation)
        System.out.println("출발!");
    }
}
```

**Car has-a Engine** → 내부 구현을 숨기고 필요한 동작만 위임.

## 상속의 문제점

```java
// 문제 1: 캡슐화 파괴 — 부모 내부 구현에 의존
class InstrumentedHashSet<E> extends HashSet<E> {
    private int addCount = 0;

    @Override public boolean add(E e) {
        addCount++;
        return super.add(e);
    }

    @Override public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return super.addAll(c);   // 내부에서 add()를 호출 → addCount 이중 증가
    }
}

// addAll(List.of(1,2,3)) → addCount = 6 (예상: 3)

// 문제 2: 강한 결합 — 부모 변경 시 자식 모두 영향
// 문제 3: 불필요한 메서드 상속 — 부모의 모든 public API가 노출
```

## 합성으로 해결

```java
class InstrumentedSet<E> {
    private final Set<E> set;   // 합성
    private int addCount = 0;

    InstrumentedSet(Set<E> set) { this.set = set; }

    public boolean add(E e) {
        addCount++;
        return set.add(e);      // 위임 — 내부 구현에 의존 안 함
    }

    public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return set.addAll(c);
    }

    public int getAddCount() { return addCount; }
}
```

## 언제 무엇을 쓰나

| | 상속 | 합성 |
|---|---|---|
| 관계 | is-a (진정한 하위 타입) | has-a (기능 위임) |
| 결합도 | 높음 (부모 변경 시 영향) | 낮음 (인터페이스로 분리 가능) |
| 캡슐화 | 부모 내부 노출 위험 | 내부 구현 완전 은닉 |
| 유연성 | 낮음 (컴파일 타임 고정) | 높음 (런타임 교체 가능) |
| 권장 | 명확한 계층 관계 | 기본 선택 (Effective Java) |

> "상속보다 합성을 선호하라" — Effective Java Item 18

## 핵심 정리

- 상속: is-a 관계 + 부모의 API를 그대로 외부에 노출해도 되는 경우에만 사용

- 합성: 기능만 빌려 쓰고 싶을 때 — 캡슐화를 지키며 결합도를 낮춤

- 상속 남용 시 부모 내부 구현 변경에 자식이 의도치 않게 깨지는 취약한 기반 클래스 문제 발생

→ [[다형성]] | [[캡슐화]] | [[SOLID]]

