---
title: "equals와 hashCode는 왜 함께 재정의해야 할까요"
tags: [매일메일, Backend]
status: published
---

[[equals와 hashCode]]는 객체의 동등성 비교와 해시값 생성을 위해 사용됩니다. 둘 중 하나만 재정의하면 `HashSet`, `HashMap` 같은 해시 기반 자료구조에서 예상과 다른 결과가 나올 수 있습니다.

## equals와 hashCode의 계약

Java에서 `equals()`가 `true`인 두 객체는 반드시 같은 `hashCode()` 값을 가져야 합니다. 반대로 `hashCode()`가 같다고 해서 반드시 `equals()`가 `true`일 필요는 없습니다. 해시 충돌이 가능하기 때문입니다.

```text
equals() true  -> hashCode() 같아야 함
hashCode() 같음 -> equals() true일 필요는 없음
```

## equals만 재정의하면 생기는 문제

해시 기반 자료구조는 먼저 `hashCode()`로 버킷을 찾고, 같은 버킷 안에서 `equals()`로 동등성을 비교합니다.

```java
class Subscribe {
    private final String email;
    private final String category;

    Subscribe(String email, String category) {
        this.email = email;
        this.category = category;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Subscribe that)) return false;
        return Objects.equals(email, that.email)
                && Objects.equals(category, that.category);
    }
}
```

이 클래스는 `equals()`만 재정의하고 `hashCode()`를 재정의하지 않았습니다. 그러면 내용이 같은 객체라도 Object의 기본 `hashCode()`를 사용해 서로 다른 해시값을 가질 수 있습니다.

```java
Set<Subscribe> set = new HashSet<>();
set.add(new Subscribe("team.maeilmail@gmail.com", "backend"));
set.add(new Subscribe("team.maeilmail@gmail.com", "backend"));

System.out.println(set.size()); // 2가 될 수 있음
```

## 올바른 구현

`equals()` 비교에 사용한 필드를 `hashCode()`에도 함께 사용해야 합니다.

```java
@Override
public int hashCode() {
    return Objects.hash(email, category);
}
```

## 정리

`equals()`와 `hashCode()`는 해시 기반 자료구조에서 함께 동작합니다. 논리적으로 같은 객체가 같은 버킷에서 비교될 수 있도록, `equals()`를 재정의할 때는 반드시 `hashCode()`도 함께 재정의해야 합니다.
