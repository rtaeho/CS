캐시 만료 전에 **확률적으로 미리 갱신**해 캐시 스탬피드를 방지하는 알고리즘입니다.

## 핵심 아이디어

```
기존 방식: 만료 후 갱신
─────────────────────┬──────────────────
                   만료!         ← 이 순간 요청이 몰림
                     └→ DB 조회 후 갱신

PER 방식: 만료 전 미리 갱신
──────────────────┬──────────────────
               여기서 미리 갱신!  ← 만료 전 확률적으로 선제 갱신
               (만료까지 아직 시간 남음)
```

## 공식

```
현재 시각 - (β × δ × ln(random)) > 만료 시각 - TTL

β    : 갱신 민감도 (보통 1.0)
δ    : 캐시 갱신에 걸리는 시간 (계산 비용)
random : 0~1 사이 난수
ln   : 자연로그
```

> 남은 TTL이 짧을수록, 갱신 비용(δ)이 클수록 갱신 확률이 높아집니다.

## 구현

```java
class PERCache {
    private final Map<String, CacheEntry> store = new HashMap<>();

    static class CacheEntry {
        String value;
        long expireAt;  // 만료 시각 (ms)
        long delta;     // 캐시 갱신 소요 시간 (ms)
    }

    String get(String key, Supplier<String> dbQuery) {
        CacheEntry entry = store.get(key);

        if (entry != null) {
            double beta = 1.0;
            // 핵심 공식: 남은 TTL이 짧을수록 갱신 확률 증가
            double score = System.currentTimeMillis()
                         - beta * entry.delta * Math.log(Math.random());

            if (score < entry.expireAt) {
                return entry.value;  // 아직 갱신 불필요
            }
        }

        // 캐시 갱신
        long start = System.currentTimeMillis();
        String value = dbQuery.get();           // DB 조회
        long delta = System.currentTimeMillis() - start;

        CacheEntry newEntry = new CacheEntry();
        newEntry.value    = value;
        newEntry.expireAt = System.currentTimeMillis() + TTL;
        newEntry.delta    = delta;
        store.put(key, newEntry);

        return value;
    }
}
```

## 동작 예시

```
TTL = 300초, β = 1.0, δ = 30ms 일 때

만료까지 200초 남음 → 갱신 확률 낮음  → 대부분 캐시 반환
만료까지  10초 남음 → 갱신 확률 높음  → 미리 갱신 시작
만료까지   1초 남음 → 갱신 확률 매우 높음 → 거의 확실히 갱신
```

## 다른 방법과 비교

|방법|동시 DB 요청 방지|대기 시간|구현 복잡도|
|---|---|---|---|
|뮤텍스 락|완전 방지 O|발생|보통|
|PER 알고리즘|확률적 방지|없음 O|복잡|
|TTL 분산|부분 방지|없음 O|단순 O|
|백그라운드 갱신|완전 방지 O|없음 O|복잡|

## 특징

| 항목     | 내용                         |
| ------ | -------------------------- |
| 장점     | 대기 없이 자연스러운 갱신, 락 불필요      |
| 단점     | 일부 요청이 갱신 비용 부담, 완전한 방지 아님 |
| 적합한 경우 | 갱신 비용이 크고 동시 요청이 많은 캐시     |

> PER은 락 없이 스탬피드를 완화하지만 완전한 해결책은 아닙니다. 실무에서는 **뮤텍스 락 또는 백그라운드 갱신과 병행**해 사용하는 경우가 많습니다.