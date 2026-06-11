객체를 **참조하는 횟수를 카운팅**하여 카운트가 0이 되면 메모리를 해제하는 GC 방식입니다.

## 동작 방식

```
객체 생성      → count = 1
참조 추가      → count++
참조 해제      → count--
count == 0   → 메모리 해제 O
```

## 예시

```python
# Python은 Reference Counting 방식 사용
a = [1, 2, 3]  # count = 1
b = a          # count = 2
a = None       # count = 1
b = None       # count = 0 → 메모리 해제 O
```

## 순환 참조 문제

```
A → B → A (서로 참조)

A.count = 1 (B가 참조)
B.count = 1 (A가 참조)

외부에서 A, B 참조 해제해도
→ 서로 참조하므로 count가 0이 되지 않음
→ 메모리 해제 불가
```

```python
# 순환 참조 예시
class Node:
    def __init__(self):
        self.ref = None

a = Node()
b = Node()
a.ref = b  # a → b
b.ref = a  # b → a (순환 참조)

a = None
b = None
# count가 0이 안 되어 메모리 누수 발생
```

## 순환 참조 해결

```
Python: 주기적으로 순환 참조 탐지하는 보조 GC 사용
Java: Reference Counting 대신 Reachability 방식 사용
     → 순환 참조해도 GC Root에서 도달 불가면 수거 O
```

## Reachability와 비교

||Reference Counting|Reachability|
|---|---|---|
|**해제 시점**|즉시 (count = 0)|GC 실행 시|
|**순환 참조**|해결 불가|해결 가능 O|
|**STW**|없음|발생|
|**오버헤드**|count 관리 비용|탐색 비용|
|**사용 언어**|Python, Swift|Java, C#|

> Reference Counting은 **즉시 메모리 해제**가 가능하다는 장점이 있지만, **순환 참조 문제**로 인해 Java는 Reachability 방식을 채택했습니다.