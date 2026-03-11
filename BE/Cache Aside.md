애플리케이션이 **캐시를 직접 관리하는 가장 일반적인 캐싱 전략**입니다.

## 동작 방식

```
읽기 (Read)
────────────────────────────────
1. 캐시 먼저 조회
        ↓
   캐시 Hit?
   ✅ Yes → 캐시에서 반환 (끝)
   ❌ No  → DB 조회 → 캐시에 저장 → 반환

쓰기 (Write)
────────────────────────────────
1. DB에 직접 저장
2. 캐시 삭제 (or 업데이트)
```

## 코드 예시

```java
@Service
public class UserService {
    private final UserRepository userRepository;
    private final RedisTemplate<String, User> redisTemplate;

    // 읽기
    public User getUser(Long id) {
        String cacheKey = "user:" + id;

        // 1. 캐시 먼저 확인
        User cached = redisTemplate.opsForValue().get(cacheKey);
        if (cached != null) {
            return cached;  // ✅ Cache Hit
        }

        // 2. Cache Miss → DB 조회
        User user = userRepository.findById(id).orElseThrow();

        // 3. 캐시에 저장 (TTL 10분)
        redisTemplate.opsForValue().set(cacheKey, user, 10, TimeUnit.MINUTES);

        return user;
    }

    // 쓰기
    public void updateUser(Long id, UserUpdateRequest request) {
        // 1. DB 업데이트
        userRepository.update(id, request);

        // 2. 캐시 삭제 (다음 조회 시 DB에서 최신값 로드)
        redisTemplate.delete("user:" + id);
    }
}
```

## 다른 캐싱 전략과 비교

|전략|캐시 관리 주체|특징|
|---|---|---|
|**Cache Aside**|애플리케이션|직접 관리, 유연함|
|**Read Through**|캐시|캐시가 DB 조회 대행|
|**Write Through**|캐시|DB + 캐시 동시 저장|
|**Write Behind**|캐시|캐시 저장 후 DB는 나중에|

## 장단점

```
장점
✅ 구조 단순, 이해하기 쉬움
✅ 캐시 장애 시 DB로 fallback 가능
✅ 필요한 데이터만 캐싱 (메모리 효율)

단점
❌ Cache Miss 시 DB 조회 + 캐시 저장으로 첫 응답 느림
❌ DB 업데이트 후 캐시 삭제 전 순간적으로 데이터 불일치 발생
❌ 캐시 관리 로직을 개발자가 직접 작성해야 함
```

## 캐시 불일치 문제

```
Thread A: DB 업데이트 완료
                        ↓
Thread B: 캐시 조회 → 아직 삭제 전 → 구버전 데이터 반환 ❌
                        ↓
Thread A: 캐시 삭제
```

```java
// TTL로 완화 → 최대 TTL 시간 내에는 불일치 허용
redisTemplate.opsForValue().set(cacheKey, user, 10, TimeUnit.MINUTES);
// 10분 후 자동 만료 → 최신 데이터로 갱신
```

> Cache Aside는 **"캐시가 없으면 DB에서 가져와서 채운다"** 는 단순한 원칙으로, 대부분의 서비스에서 Redis + RDB 조합으로 가장 많이 사용하는 전략입니다.