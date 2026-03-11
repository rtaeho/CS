캐시에 저장된 데이터가 **더 이상 유효하지 않을 때 제거하거나 갱신하는 것**입니다.

## 왜 필요한가?

```
DB 데이터 변경 → 캐시는 그대로 → 캐시와 DB 불일치
                                          ↓
                              Cache Invalidation으로 해결
```

## Invalidation 방법 3가지

### 1. TTL (Time To Live) - 만료 시간 설정

```java
// 가장 단순한 방법 - 시간이 지나면 자동 삭제
redisTemplate.opsForValue()
    .set("user:1", user, 10, TimeUnit.MINUTES);  // 10분 후 자동 만료

// 장점: 구현 단순
// 단점: TTL 동안 stale 데이터 존재 가능
```

### 2. Event-Based Invalidation - 변경 시 즉시 삭제

```java
@Service
public class UserService {

    public void updateUser(Long id, UserUpdateRequest request) {
        // DB 업데이트
        userRepository.update(id, request);

        // 변경 즉시 캐시 삭제
        redisTemplate.delete("user:" + id);  // 다음 조회 시 DB에서 최신값 로드
    }

    // 연관 캐시 전체 삭제
    public void updateUserDept(Long deptId) {
        deptRepository.update(deptId);

        // 해당 부서 관련 캐시 전체 삭제
        Set<String> keys = redisTemplate.keys("dept:" + deptId + "*");
        redisTemplate.delete(keys);
    }
}
```

### 3. Spring @CacheEvict - 선언적 캐시 삭제

```java
@Service
public class UserService {

    // 조회 시 캐시 저장
    @Cacheable(value = "users", key = "#id")
    public User getUser(Long id) {
        return userRepository.findById(id).orElseThrow();
    }

    // 업데이트 시 캐시 삭제
    @CacheEvict(value = "users", key = "#id")
    public void updateUser(Long id, UserUpdateRequest request) {
        userRepository.update(id, request);
    }

    // 전체 캐시 삭제
    @CacheEvict(value = "users", allEntries = true)
    public void deleteAll() {
        userRepository.deleteAll();
    }

    // 캐시 업데이트 (삭제 후 재저장)
    @CachePut(value = "users", key = "#id")
    public User updateAndCache(Long id, UserUpdateRequest request) {
        return userRepository.update(id, request);
    }
}
```

## Invalidation 전략 비교

|전략|시점|정합성|구현 난이도|
|---|---|---|---|
|**TTL**|시간 만료 시|낮음 (stale 허용)|✅ 단순|
|**Event-Based**|데이터 변경 시 즉시|높음|🔺 보통|
|**@CacheEvict**|메서드 실행 시|높음|✅ 단순|

## 주의 - Cache Stampede

```
캐시 만료 순간 대량 요청 → 모두 DB로 → DB 과부하

시간 →
캐시 만료!
요청1 → DB 조회 중...
요청2 → DB 조회 중...   ← 동시에 몰림 ❌
요청3 → DB 조회 중...
```

```java
// 해결책 1: 뮤텍스 락
public User getUser(Long id) {
    User cached = redisTemplate.opsForValue().get("user:" + id);
    if (cached != null) return cached;

    // 락 획득한 스레드만 DB 조회
    String lockKey = "lock:user:" + id;
    Boolean locked = redisTemplate.opsForValue()
        .setIfAbsent(lockKey, "1", 3, TimeUnit.SECONDS);

    if (locked) {
        User user = userRepository.findById(id).orElseThrow();
        redisTemplate.opsForValue().set("user:" + id, user, 10, TimeUnit.MINUTES);
        redisTemplate.delete(lockKey);
        return user;
    }

    // 락 못 얻은 스레드 → 잠깐 대기 후 캐시 재조회
    Thread.sleep(50);
    return getUser(id);
}

// 해결책 2: TTL에 랜덤값 추가 → 만료 시점 분산
int ttl = 600 + new Random().nextInt(60);  // 600~660초
redisTemplate.opsForValue().set("user:" + id, user, ttl, TimeUnit.SECONDS);
```

> Cache Invalidation은 **"언제 캐시를 믿을 수 없게 되는가"** 를 관리하는 것입니다. 컴퓨터 과학에서 가장 어려운 문제 중 하나로 꼽히며, 정합성과 성능 사이의 트레이드오프를 항상 고려해야 합니다.