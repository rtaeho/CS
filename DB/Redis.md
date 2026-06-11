데이터를 **메모리에 저장**하는 오픈소스 key-value 데이터 저장소로, 주로 캐시, 세션, 메시지 브로커로 활용됩니다.

## 핵심 특징

```
일반 DB: 디스크에 저장 → 느림
Redis:   메모리에 저장 → 매우 빠름 (읽기/쓰기 ~100,000 ops/sec)
```

## 지원 자료구조

```java
// String
redis.set("name", "Alice");
redis.get("name");              // "Alice"

// List
redis.lpush("queue", "task1"); // 앞에 삽입
redis.rpop("queue");           // 뒤에서 꺼냄

// Set
redis.sadd("tags", "java", "redis");
redis.smembers("tags");        // {"java", "redis"}

// Sorted Set (score 기반 정렬)
redis.zadd("ranking", 100, "Alice");
redis.zadd("ranking", 200, "Bob");
redis.zrange("ranking", 0, -1); // 점수순 조회

// Hash (객체 저장)
redis.hset("user:1", "name", "Alice");
redis.hset("user:1", "age", "25");
redis.hgetall("user:1");       // {"name":"Alice", "age":"25"}
```

## 주요 활용

### 1. 캐시

```java
// DB 조회 전 캐시 확인
String value = redis.get("user:1");
if (value == null) {
    value = db.findUser(1);       // DB 조회
    redis.setex("user:1", 300, value); // 300초 TTL로 캐시 저장
}
return value;
```

### 2. 세션 저장

```java
// 로그인 시 세션 저장
redis.setex("session:" + token, 1800, userId); // 30분 TTL

// 요청마다 세션 확인
String userId = redis.get("session:" + token);
```

### 3. 분산 락

```java
// 뮤텍스 구현 (앞서 캐시 스탬피드에서 나온 내용)
redis.setnx("lock:key", "1");  // 락 획득
redis.del("lock:key");         // 락 해제
```

### 4. 메시지 브로커 (Pub/Sub)

```java
// 발행
redis.publish("channel", "message");

// 구독
redis.subscribe("channel", (message) -> {
    System.out.println("받은 메시지: " + message);
});
```

## 영속성 옵션

|방식|설명|특징|
|---|---|---|
|RDB|주기적 스냅샷 저장|빠른 복구, 데이터 유실 가능|
|AOF|모든 쓰기 명령 로그|데이터 유실 최소화, 느림|
|없음|메모리만 사용|가장 빠름, 재시작 시 데이터 소멸|

## Redis vs Memcached

|항목|Redis|Memcached|
|---|---|---|
|자료구조|다양 O|String만|
|영속성|지원 O|미지원|
|클러스터|지원 O|제한적|
|Pub/Sub|지원 O|미지원|
|성능|빠름|빠름|

> Redis는 단순 캐시를 넘어 **분산 시스템의 핵심 인프라**로 활용됩니다. 메모리 기반이므로 **비용이 비싸**, 자주 조회되고 변경이 적은 데이터를 선별해 저장하는 것이 중요합니다.