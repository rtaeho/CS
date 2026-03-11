데이터를 쓸 때 **캐시와 DB에 동시에 저장하는 캐싱 전략**입니다.

## 동작 방식

```
Write Through
────────────────────────────────
1. 캐시에 저장
2. DB에 저장 (동기적으로 함께)
3. 완료

Cache Aside (비교)
────────────────────────────────
1. DB에 저장
2. 캐시 삭제
3. 다음 조회 시 캐시 재적재
```

## 코드 예시

```java
@Service
public class UserService {

    // Write Through
    public void updateUser(Long id, UserUpdateRequest request) {
        User user = userRepository.findById(id).orElseThrow();
        user.update(request);

        // 1. DB 저장
        userRepository.save(user);

        // 2. 캐시도 동시에 업데이트 (삭제가 아닌 최신값으로 갱신)
        redisTemplate.opsForValue()
            .set("user:" + id, user, 10, TimeUnit.MINUTES);
    }

    // 읽기는 Cache Aside와 동일
    public User getUser(Long id) {
        String cacheKey = "user:" + id;
        User cached = redisTemplate.opsForValue().get(cacheKey);
        if (cached != null) return cached;

        User user = userRepository.findById(id).orElseThrow();
        redisTemplate.opsForValue().set(cacheKey, user, 10, TimeUnit.MINUTES);
        return user;
    }
}
```

## Cache Aside vs Write Through

```
Cache Aside (쓰기)
DB 업데이트 → 캐시 삭제 → 다음 조회 시 캐시 재적재
→ 순간적인 불일치 발생 가능 ❌
→ 불필요한 데이터는 캐싱 안 됨 ✅

Write Through (쓰기)
DB 업데이트 → 캐시도 동시에 업데이트
→ 항상 캐시와 DB 일치 ✅
→ 쓰지 않는 데이터도 캐시에 남을 수 있음 ❌
```

## 장단점

```
장점
✅ 캐시와 DB 항상 일치 (데이터 정합성 보장)
✅ Cache Miss 거의 없음 (읽기 성능 좋음)
✅ 캐시 삭제/재적재 과정 없음

단점
❌ 쓰기 시 캐시 + DB 두 곳에 저장 → 쓰기 지연 증가
❌ 자주 쓰이지 않는 데이터도 캐시에 적재 → 메모리 낭비
❌ 캐시 장애 시 쓰기 실패 위험
```

## 전략별 비교 정리

| 전략                | 읽기   | 쓰기           | 정합성       | 적합한 상황    |
| ----------------- | ---- | ------------ | --------- | --------- |
| **Cache Aside**   | Lazy | DB → 캐시 삭제   | 순간 불일치 가능 | 읽기 多, 범용적 |
| **Write Through** | Lazy | 캐시 + DB 동시   | 항상 일치     | 읽기/쓰기 균형  |
| **Write Behind**  | Lazy | 캐시만 → DB 나중에 | 일시적 불일치   | 쓰기 多      |

> Write Through는 **"쓰기 성능을 일부 희생하고 정합성을 얻는 전략"** 입니다. 데이터 불일치가 치명적인 서비스(잔액, 재고 등)에서 Cache Aside보다 유리합니다.