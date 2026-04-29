[[HashMap]]에 키가 **없으면 값을 저장**하고, **있으면 기존 값과 새 값을 함수로 병합**합니다. 카운팅·누적 패턴을 한 줄로 압축합니다.

## 시그니처

```java
V merge(K key, V value, BiFunction<V, V, V> remappingFunction)
```

|상황|동작|
|---|---|
|키 없음 / 값이 null|`value` 저장|
|키 있음|`remappingFunction(기존값, value)` 결과로 갱신|
|함수가 null 반환|해당 키 삭제|

## 동작 추적

```java
Map<String, Integer> map = new HashMap<>();
```

```
[ 초기 상태 ]
map: { }
```

### 첫 등장

```java
map.merge("apple", 1, Integer::sum);
```

```
[ 동작 ]
"apple" 키 없음 → value(=1) 그대로 저장 (함수 호출 안 함)

[ 변경 후 ]
map: { apple=1 }
```

### 재등장

```java
map.merge("apple", 1, Integer::sum);
```

```
[ 동작 ]
"apple" 키 있음 (값 1) → Integer::sum(1, 1) = 2

[ 변경 후 ]
map: { apple=2 }
```

```java
map.merge("apple", 5, Integer::sum);
```

```
[ 동작 ]
"apple" 키 있음 (값 2) → Integer::sum(2, 5) = 7

[ 변경 후 ]
map: { apple=7 }
```

## 왜 merge인가? — 카운팅 패턴 비교

```java
String[] participant = {"mislav", "stanko", "mislav", "ana"};
Map<String, Integer> map = new HashMap<>();

// 방법 1: containsKey + get + put — 가장 장황
for (String name : participant) {
    if (map.containsKey(name)) {
        map.put(name, map.get(name) + 1);
    } else {
        map.put(name, 1);
    }
}

// 방법 2: getOrDefault — 한 줄
for (String name : participant) {
    map.put(name, map.getOrDefault(name, 0) + 1);
}

// 방법 3: merge — 가장 간결
for (String name : participant) {
    map.merge(name, 1, Integer::sum);
}
```

```
[ 단계별 추적 — merge 방식 ]

초기:                       { }

merge("mislav", 1, sum):
  키 없음 → 1 저장          { mislav=1 }

merge("stanko", 1, sum):
  키 없음 → 1 저장          { mislav=1, stanko=1 }

merge("mislav", 1, sum):
  키 있음 (1) → sum(1, 1) = 2
                            { mislav=2, stanko=1 }

merge("ana", 1, sum):
  키 없음 → 1 저장          { mislav=2, stanko=1, ana=1 }
```

## 자주 쓰는 패턴

### 차감 (0 되면 자동 삭제)

```java
// 함수가 null 반환하면 키 자동 삭제
Map<String, Integer> map = new HashMap<>();
map.put("apple", 2);
map.put("banana", 1);
```

```
[ 초기 상태 ]
map: { apple=2, banana=1 }
```

```java
String[] consumed = {"apple", "banana", "apple"};

for (String key : consumed) {
    map.merge(key, -1, (oldVal, delta) -> {
        int v = oldVal + delta;
        return v == 0 ? null : v;   // 0이면 삭제
    });
}
```

```
[ 단계별 추적 ]

"apple":
  merge → 2 + (-1) = 1 (≠0) → 갱신
       { apple=1, banana=1 }

"banana":
  merge → 1 + (-1) = 0 → null 반환 → 삭제
       { apple=1 }

"apple":
  merge → 1 + (-1) = 0 → null 반환 → 삭제
       { }
```

### 그룹 합계 (부서별 급여)

```java
class Employee {
    String dept; long salary;
    Employee(String d, long s) { dept = d; salary = s; }
    String getDept() { return dept; }
    long getSalary() { return salary; }
}

List<Employee> employees = List.of(
    new Employee("개발", 5000L),
    new Employee("개발", 6000L),
    new Employee("기획", 4500L),
    new Employee("개발", 5500L)
);

Map<String, Long> deptTotal = new HashMap<>();
for (Employee e : employees) {
    deptTotal.merge(e.getDept(), e.getSalary(), Long::sum);
}
```

```
[ 단계별 추적 ]

초기:                            { }

merge("개발", 5000):              { 개발=5000 }
merge("개발", 6000):              { 개발=11000 }
merge("기획", 4500):              { 개발=11000, 기획=4500 }
merge("개발", 5500):              { 개발=16500, 기획=4500 }
```

### 문자열 누적

```java
Map<String, String> map = new HashMap<>();
map.merge("greeting", "Hello", (a, b) -> a + ", " + b);
map.merge("greeting", "World", (a, b) -> a + ", " + b);
map.merge("greeting", "Java",  (a, b) -> a + ", " + b);
```

```
[ 단계별 추적 ]

초기:                                          { }
merge("greeting", "Hello"):                    { greeting=Hello }
merge("greeting", "World"):                    { greeting=Hello, World }
merge("greeting", "Java"):                     { greeting=Hello, World, Java }
```

## 주의

```
value 자체가 null이면 → NullPointerException
함수 결과가 null이면 → 키 삭제 (정상 동작)
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1) + 람다 비용|O(n) / O(log n) (Java 8+ 트리화)|
