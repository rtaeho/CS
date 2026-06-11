키(Key)와 값(Value)을 쌍으로 저장하며, 해시 함수를 통해 **평균 O(1)에 데이터를 저장·조회**하는 자료구조입니다.

## 구조

```
Key → 해시 함수 → index → 배열(버킷)에 저장

"apple"  → hash() → 2 → bucket[2]에 저장
"banana" → hash() → 5 → bucket[5]에 저장

bucket:
[0] null
[1] null
[2] ["apple"  | 1000]
[3] null
[4] null
[5] ["banana" | 2000]
```

## [[해시 충돌]]과 해결

서로 다른 키가 같은 인덱스를 가리키는 경우입니다.

```
"apple"  → hash() → 2
"grape"  → hash() → 2  ← 충돌!
```

Java의 HashMap은 [[분리 연결법]] (체이닝) 사용:

```
같은 버킷에 링크드 리스트로 연결:
bucket[2]: ["apple"|1000] → ["grape"|3000] → null

Java 8부터 체인 길이 8 이상이면
LinkedList → Red-Black Tree로 자동 전환 → O(log n)
```

## 자주 쓰는 메서드

|메서드|용도|시간|
|---|---|---|
|[[HashMap.put]]|키-값 저장|O(1)|
|[[HashMap.get]]|키로 값 조회|O(1)|
|[[HashMap.getOrDefault]]|없으면 기본값 반환|O(1)|
|[[HashMap.containsKey]]|키 존재 확인|O(1)|
|[[HashMap.remove]]|키 삭제|O(1)|
|[[HashMap.putIfAbsent]]|없을 때만 저장|O(1)|
|[[HashMap.keySet]]|키 집합 반환|O(1)|
|[[HashMap.values]]|값 컬렉션 반환|O(1)|
|[[HashMap.entrySet]]|키-값 쌍 집합 반환|O(1)|
|[[HashMap.merge]]|기존값과 병합|O(1)|
|[[HashMap.compute]]|키에 함수 적용|O(1)|

## 시간복잡도

|연산|평균|최악 (충돌 많을 때)|
|---|---|---|
|삽입|O(1)|O(n)|
|조회|O(1)|O(n)|
|삭제|O(1)|O(n)|

## 로드 팩터 (Load Factor)

```
로드 팩터 = 저장된 데이터 수 / 버킷 크기

기본값: 0.75 (75% 차면 버킷 크기 2배 확장 → rehashing)
```

> 로드 팩터가 낮을수록 충돌 감소, 메모리 낭비 증가
> 로드 팩터가 높을수록 충돌 증가, 메모리 효율 증가

## HashMap vs HashTable vs LinkedHashMap

|항목|HashMap|HashTable|LinkedHashMap|
|---|---|---|---|
|동기화|X|O|X|
|null 키 허용|O|X|O|
|순서 보장|X|X|삽입 순서 O|
|성능|빠름|느림|약간 느림|

> 멀티스레드 환경에서는 `HashTable` 대신 **`ConcurrentHashMap`** 사용을 권장합니다.

## 핵심 정리

HashMap은 **해시 함수로 키를 인덱스에 매핑**하여 평균 O(1) 시간에 저장·조회·삭제가 가능한 자료구조입니다. 충돌은 [[분리 연결법]]으로 해결하며 Java 8부터는 체인 길이 8 이상일 때 트리로 전환되어 최악 O(log n)을 보장합니다. 로드 팩터 0.75를 넘으면 버킷이 2배로 확장되며, 멀티스레드 환경에서는 `ConcurrentHashMap`을 사용해야 합니다.
