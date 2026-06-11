---
title: "Reachability"
tags: [Java, GC, 메모리]
status: published
---

**GC Root에서 시작하여 참조를 따라가며 도달 가능한 객체를 탐색**하고, 도달할 수 없는 객체를 수거하는 GC 방식입니다.

## 동작 방식

```
GC Root에서 참조 그래프 탐색 시작
→ 도달 가능(Reachable)   → 살아있는 객체 O
→ 도달 불가(Unreachable) → 수거 대상
```

## GC Root 종류

```
- 스택(Stack)의 지역 변수
- 정적(static) 변수
- JNI(네이티브 코드)에서 참조하는 객체
```

## 순환 참조 해결

```
A → B → A (순환 참조)
외부에서 A, B 참조 해제

GC Root → A 도달 불가
GC Root → B 도달 불가
→ 순환 참조여도 수거 가능 O
```

## 탐색 과정

```
GC Root
├── Object A (Reachable O)
│   └── Object B (Reachable O)
│       └── Object C (Reachable O)
├── Object D (Reachable O)
└── (끊김)
    Object E (Unreachable) → 수거
    Object F (Unreachable) → 수거
    Object G ↔ Object H (순환참조, Unreachable) → 수거
```

## Reference Counting과 비교

||Reference Counting|Reachability|
|---|---|---|
|**순환 참조**|해결 불가|해결 가능 O|
|**해제 시점**|즉시|GC 실행 시|
|**STW**|없음|발생|
|**사용 언어**|Python, Swift|Java, C#|

> Java는 Reachability 방식을 사용하기 때문에 **순환 참조가 발생해도 메모리 누수가 없으며**, GC Root에서 도달 불가능한 객체는 모두 수거됩니다.