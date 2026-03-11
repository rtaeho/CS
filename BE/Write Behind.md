데이터를 쓸 때 **캐시에만 먼저 저장하고, DB에는 나중에 비동기로 저장하는 캐싱 전략**입니다.

## 동작 방식

```
Write Through (비교)
────────────────────────────────
요청 → 캐시 저장 → DB 저장 → 응답
       (동기)      (동기)
       둘 다 완료해야 응답 가능 → 느림

Write Behind
────────────────────────────────
요청 → 캐시 저장 → 응답  (빠름!)
              ↓
         Queue에 적재
              ↓
         DB에 비동기 저장 (나중에)
```

## 코드 예시

```java
@Service
public class UserService {
    private final RedisTemplate<String, User> redisTemplate;
    private final BlockingQueue<WriteTask> writeQueue = new LinkedBlockingQueue<>();

    // 쓰기 - 캐시만 즉시 저장
    public void updateUser(Long id, UserUpdateRequest request) {
        User user = buildUser(id, request);

        // 1. 캐시 즉시 저장 → 바로 응답
        redisTemplate.opsForValue().set("user:" + id, user);

        // 2. DB 저장은 Queue에 적재 → 비동기 처리
        writeQueue.offer(new WriteTask(id, user));
    }

    // 백그라운드에서 DB에 배치 저장
    @Scheduled(fixedDelay = 1000)  // 1초마다
    public void flushToDB() {
        List<WriteTask> tasks = new ArrayList<>();
        writeQueue.drainTo(tasks);  // Queue에 쌓인 것 모두 꺼내기

        if (!tasks.isEmpty()) {
            // 배치로 한번에 DB 저장 → DB 부하 감소
            userRepository.saveAll(tasks.stream()
                .map(WriteTask::getUser)
                .collect(toList()));
        }
    }
}
```

## 전략별 쓰기 흐름 비교

```
Cache Aside
요청 → DB 저장 → 캐시 삭제 → 응답
       (동기)

Write Through
요청 → 캐시 저장 → DB 저장 → 응답
       (동기)       (동기)

Write Behind
요청 → 캐시 저장 → 응답
       (동기)
            ↓ (비동기)
          DB 저장
```

## 장단점

```
장점
✅ 쓰기 응답 속도 매우 빠름 (캐시만 저장 후 즉시 응답)
✅ DB에 배치로 모아서 저장 → DB 부하 감소
✅ 쓰기가 폭발적으로 많은 상황에 유리

단점
❌ 캐시 장애 시 DB에 저장 안 된 데이터 유실 위험
❌ 캐시와 DB 일시적 불일치
❌ 구현 복잡도 높음
```

## 데이터 유실 위험

```
캐시 저장 완료
Queue에 적재
    ↓
Redis 장애 발생! 💥
    ↓
Queue에 있던 데이터 전부 유실 ❌
DB에는 저장 안 됨
```

```java
// 유실 방지 - Redis AOF(Append Only File) 설정
// redis.conf
appendonly yes          // 모든 쓰기를 로그로 기록
appendfsync everysec    // 1초마다 디스크에 동기화

// 장애 복구 시 AOF 로그로 데이터 복원 가능
```

## 언제 사용하나?

|상황|적합 여부|
|---|---|
|쓰기가 매우 잦은 서비스|✅ (게임 점수, 좋아요 수)|
|실시간 로그/이벤트 수집|✅|
|금융/결제 데이터|❌ (데이터 유실 치명적)|
|정합성이 중요한 도메인|❌|

## 3가지 전략 최종 비교

|전략|쓰기 성능|읽기 성능|정합성|복잡도|
|---|---|---|---|---|
|**Cache Aside**|보통|보통|순간 불일치|낮음|
|**Write Through**|느림|빠름|항상 일치|보통|
|**Write Behind**|매우 빠름|빠름|일시 불일치|높음|

> Write Behind는 **"속도를 위해 안정성을 일부 포기하는 전략"** 입니다. 좋아요 수, 조회수, 게임 점수처럼 **약간의 유실이 허용되는 대용량 쓰기**에 적합합니다.
