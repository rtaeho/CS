JDBC 커넥션 풀 라이브러리로, 바이트코드 최적화와 경량 설계로 가장 빠른 성능을 제공하며 Spring Boot 2.0+의 기본 커넥션 풀입니다.

## 왜 HikariCP인가?

"Hikari"는 일본어로 **빛(光)**이라는 뜻으로, 빛처럼 빠르다는 의미를 담고 있습니다.

```
벤치마크 (커넥션 획득/반납, ops/ms)

HikariCP   ████████████████████████████████████  ~35,000
Tomcat     ████████████                          ~12,000
DBCP2      ██████████                            ~10,000
C3P0       ████                                  ~ 4,000
```

## HikariCP가 빠른 이유

### 1. FastList

기본 `ArrayList` 대신 자체 구현한 `FastList`를 사용합니다.

```java
// ArrayList.get() — 매번 범위 체크
public E get(int index) {
    rangeCheck(index);       // if (index >= size) throw ...
    return elementData[index];
}

// FastList.get() — 범위 체크 생략
public T get(int index) {
    return elementData[index]; // 바로 접근, 미세한 차이가 누적됨
}
```

### 2. ConcurrentBag

커넥션 관리에 락(Lock) 경합을 최소화하는 자체 자료구조를 사용합니다.

```
[ ConcurrentBag 동작 ]

스레드 A가 커넥션 요청:
  1단계: ThreadLocal에서 이전에 사용한 커넥션 검색 (락 없음, 가장 빠름)
  2단계: 없으면 → 공유 리스트(sharedList)에서 CAS 연산으로 획득
  3단계: 없으면 → handoffQueue에서 대기 (다른 스레드가 반납할 때까지)
```

|단계|방식|락 경합|
|---|---|---|
|ThreadLocal 탐색|자기 스레드 전용|없음|
|sharedList CAS|Compare-And-Swap|최소|
|handoffQueue 대기|블로킹|있음 (최후 수단)|

### 3. 프록시 최적화

JDBC Connection, Statement, ResultSet의 프록시를 **바이트코드 수준**에서 최적화하여 JDK Proxy나 CGLIB보다 오버헤드가 적습니다.

```
[일반 커넥션 풀]
conn.prepareStatement() → 프록시 인터셉트 (리플렉션) → 실제 호출
                          (느림)

[HikariCP]
conn.prepareStatement() → 프록시 인터셉트 (바이트코드 직접 호출) → 실제 호출
                          (빠름)
```

## 주요 설정

```yaml
spring:
  datasource:
    hikari:
      # === 풀 크기 ===
      maximum-pool-size: 10      # 최대 커넥션 수
      minimum-idle: 10           # 최소 유휴 커넥션 (공식: max와 동일 권장)

      # === 타임아웃 ===
      connection-timeout: 3000   # 커넥션 획득 대기 (ms, 기본 30초)
      idle-timeout: 600000       # 유휴 커넥션 제거 시간 (ms, 기본 10분)
      max-lifetime: 1800000      # 커넥션 최대 수명 (ms, 기본 30분)
      validation-timeout: 5000   # 커넥션 유효성 검사 타임아웃 (ms)

      # === 커넥션 검증 ===
      connection-test-query: SELECT 1   # JDBC4 미지원 드라이버용
      # JDBC4 드라이버는 Connection.isValid() 자동 사용 (설정 불필요)

      # === 누수 감지 ===
      leak-detection-threshold: 2000    # 반납까지 2초 초과 시 경고 로그
```

## 핵심 설정 상세

### maximum-pool-size

```
pool size = (core_count × 2) + effective_spindle_count

예: 4코어 서버, SSD 1개
→ (4 × 2) + 1 = 9 ~ 10
```

> HikariCP 공식 문서에서는 대부분의 경우 **10개면 충분**하다고 강조합니다.

### max-lifetime

```
DB의 wait_timeout보다 2~3초 짧게 설정해야 합니다.

MySQL wait_timeout = 28800초 (8시간)
→ max-lifetime = 1800000ms (30분) 정도가 안전

이유: DB가 먼저 커넥션을 끊으면 애플리케이션은 죽은 커넥션을 사용하게 됨
```

### minimum-idle

```
[minimum-idle < maximum-pool-size 인 경우]
트래픽 증가 → 커넥션 새로 생성 → TCP handshake + 인증 → 지연 발생

[minimum-idle = maximum-pool-size (권장)]
항상 고정된 수의 커넥션 유지 → 생성/제거 오버헤드 없음
```

## 모니터링

### Micrometer + Actuator 연동

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health, metrics
```

```java
// 주요 메트릭
GET /actuator/metrics/hikaricp.connections.active    // 사용 중 커넥션
GET /actuator/metrics/hikaricp.connections.idle      // 유휴 커넥션
GET /actuator/metrics/hikaricp.connections.pending   // 대기 중 요청 ← 이 값이 높으면 위험
GET /actuator/metrics/hikaricp.connections.timeout   // 타임아웃 발생 횟수
```

### 주의해야 할 지표

|메트릭|정상|위험 신호|
|---|---|---|
|**active**|< max-pool-size|지속적으로 max에 근접|
|**pending**|0~1|지속적으로 > 0|
|**timeout**|0|증가 추세|

## 커넥션 누수 방지

```java
// ❌ 잘못된 사용: 예외 발생 시 커넥션 미반납 → 누수
Connection conn = dataSource.getConnection();
PreparedStatement ps = conn.prepareStatement("SELECT ...");
ResultSet rs = ps.executeQuery();
conn.close();  // 예외 발생 시 이 줄에 도달하지 못함

// ✅ 올바른 사용: try-with-resources로 반납 보장
try (Connection conn = dataSource.getConnection();
     PreparedStatement ps = conn.prepareStatement("SELECT ...");
     ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
        // 처리 로직
    }
}  // 예외 발생 여부와 관계없이 자동 반납
```

## 커넥션 풀 라이브러리 비교

|항목|HikariCP|DBCP2|Tomcat Pool|C3P0|
|---|---|---|---|---|
|**성능**|⭐⭐⭐|⭐⭐|⭐⭐|⭐|
|**Spring Boot 기본**|✅ (2.0+)|❌|❌|❌|
|**코드 크기**|~130KB|~200KB|~150KB|~600KB|
|**커넥션 검증**|isValid()|쿼리 기반|쿼리 기반|쿼리 기반|
|**락 전략**|CAS + ThreadLocal|synchronized|Fair/Unfair Lock|synchronized|
|**유지보수**|활발|보통|보통|거의 없음|

> **실무 팁**: HikariCP는 Spring Boot 기본이므로 별도 의존성 추가 없이 바로 사용 가능합니다. 성능 이슈 대부분은 풀 사이즈를 과도하게 크게 잡거나, 커넥션 누수에서 비롯되므로 **적절한 풀 사이즈 + leak-detection-threshold 설정 + 모니터링**이 핵심입니다.