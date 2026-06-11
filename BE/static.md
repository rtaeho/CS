**인스턴스가 아닌 클래스 자체에 속하는** 변수·메서드·블록을 선언하는 키워드입니다.

## static 변수 (클래스 변수)

```java
class Counter {
    static int count = 0;   // 모든 인스턴스가 공유
    int id;                 // 인스턴스마다 별도

    Counter() {
        count++;
        this.id = count;
    }
}

Counter a = new Counter();  // count = 1, a.id = 1
Counter b = new Counter();  // count = 2, b.id = 2
Counter.count               // 2  ← 클래스명으로 접근
```

## 메모리 위치

```
[ JVM 메모리 ]

메서드 영역 (Method Area)
  └─ Counter.class
       ├─ static int count    ← 클래스 로딩 시 1번만 생성
       └─ 메서드 bytecode

힙 (Heap)
  ├─ Counter 인스턴스 a (id=1)
  └─ Counter 인스턴스 b (id=2)
```

> static 변수는 클래스 로딩 시 메서드 영역에 1번만 생성 → 모든 인스턴스가 공유.

## static 메서드

```java
class MathUtils {
    static int add(int a, int b) { return a + b; }
}

MathUtils.add(1, 2);   // 인스턴스 생성 없이 바로 호출
```

**제약사항**:
- `this`, `super` 사용 불가 (인스턴스와 무관)
- 인스턴스 변수·메서드 접근 불가
- 오버라이딩 불가 (다형성 적용 안 됨 — 컴파일 타임에 결정)

## static 블록

클래스가 **처음 로딩될 때 한 번만** 실행. 복잡한 static 변수 초기화에 사용.

```java
class Config {
    static final Map<String, String> SETTINGS;

    static {
        SETTINGS = new HashMap<>();
        SETTINGS.put("timeout", "30");
        SETTINGS.put("retries", "3");
    }
}
```

## static 중첩 클래스

```java
class Outer {
    static class StaticNested {
        // Outer 인스턴스 없이 사용 가능
        // Outer의 static 멤버만 접근 가능
    }

    class Inner {
        // Outer 인스턴스 필요
        // Outer의 모든 멤버 접근 가능
    }
}

Outer.StaticNested nested = new Outer.StaticNested(); // O
Outer.Inner inner = new Outer().new Inner();           // Outer 인스턴스 필요
```

## 싱글톤 패턴에서의 활용

```java
public class Singleton {
    private static Singleton instance;

    private Singleton() {}

    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
}
```

## 핵심 정리

- static 멤버는 클래스 로딩 시 메서드 영역에 생성 — 인스턴스가 없어도 존재

- static 메서드는 인스턴스 변수/메서드 접근 불가, 오버라이딩 불가

- 유틸리티 메서드, 상수, 싱글톤 구현에 주로 사용

→ [[JVM]] | [[Runtime Data Area]]

