하나의 데이터베이스(Master)의 데이터를 **다른 데이터베이스(Slave/Replica)에 실시간으로 복제**하여 가용성, 읽기 성능, 데이터 안정성을 높이는 기술입니다.

## 핵심 개념

|항목|내용|
|---|---|
|**목적**|고가용성, 읽기 성능 향상, 데이터 백업|
|**구조**|Master(쓰기) + Slave/Replica(읽기)|
|**원리**|Master의 변경 사항을 Slave에 실시간 전파|
|**대표 DB**|MySQL, PostgreSQL, MongoDB, Redis|

## 기본 구조

```
           ┌──────────────┐
           │   Master DB   │
           │  (쓰기 전용)    │
           └──────┬───────┘
                  │ 변경 사항 전파 (Replication)
        ┌─────────┼─────────┐
        ▼         ▼         ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ Slave 1   │ │ Slave 2   │ │ Slave 3   │
│ (읽기 전용) │ │ (읽기 전용) │ │ (읽기 전용) │
└──────────┘ └──────────┘ └──────────┘
```

```
애플리케이션 (Spring Boot)
    │
    ├── INSERT / UPDATE / DELETE → Master DB
    │
    └── SELECT → Slave DB (여러 대에 분산)
```

## 왜 필요한가?

|문제|Replication 적용 후|
|---|---|
|DB 서버 1대에 읽기+쓰기 집중|읽기를 Slave로 분산 → Master 부하 감소|
|DB 장애 시 서비스 중단|Slave를 Master로 승격 → 서비스 지속|
|데이터 유실 위험|여러 서버에 복제본 보유 → 백업|
|읽기 성능 한계|Slave 추가로 읽기 처리량 수평 확장|

```
[Replication 없이]
모든 요청 → Master 1대
  → 읽기 80% + 쓰기 20% = 과부하

[Replication 적용]
쓰기 20% → Master
읽기 80% → Slave 3대에 분산 (각 ~27%)
  → Master 부하 대폭 감소
```

## 동작 원리 (MySQL 기준)

```
① 클라이언트가 Master에 INSERT/UPDATE/DELETE 실행
② Master가 변경 내용을 Binary Log에 기록
③ Slave의 I/O Thread가 Master의 Binary Log를 읽어옴
④ 읽어온 내용을 Slave의 Relay Log에 저장
⑤ Slave의 SQL Thread가 Relay Log를 읽어 실제 데이터에 적용

┌─────────────────────────────────────────────────────┐
│                     Master DB                        │
│                                                     │
│  클라이언트 → SQL 실행 → 데이터 변경                    │
│                           │                          │
│                     Binary Log에 기록                 │
│                           │                          │
└───────────────────────────┼──────────────────────────┘
                            │ 네트워크 전송
┌───────────────────────────┼──────────────────────────┐
│                     Slave DB                         │
│                           ▼                          │
│                   I/O Thread                         │
│                   (Binary Log 수신)                   │
│                           │                          │
│                     Relay Log에 저장                  │
│                           │                          │
│                   SQL Thread                         │
│                   (Relay Log 재실행)                   │
│                           │                          │
│                     데이터 반영 완료                    │
└──────────────────────────────────────────────────────┘
```

## Replication 방식

### 1. 비동기 복제 (Asynchronous)

```
Master: 쓰기 완료 → 클라이언트에 즉시 응답 → 이후 Slave에 전파
    │
    ├── 장점: 쓰기 성능이 빠름 (Slave 응답을 기다리지 않음)
    └── 단점: Master 장애 시 일부 데이터 유실 가능 (Replication Lag)
```

```
Master:  ──쓰기──응답──────────────→
Slave:   ──────────────복제──적용──→
                        ↑
                    Replication Lag (지연)
                    이 구간에 Master 장애 시 데이터 유실
```

### 2. 반동기 복제 (Semi-Synchronous)

```
Master: 쓰기 완료 → 최소 1개 Slave가 Relay Log에 기록 확인 → 응답
    │
    ├── 장점: 비동기보다 데이터 안전
    └── 단점: 비동기보다 쓰기 성능 약간 저하
```

```
Master:  ──쓰기──────────────ACK 확인──응답──→
Slave:   ────────복제──Relay Log 저장──ACK──→
                                   ↑
                          여기까지 확인 후 응답
```

### 3. 동기 복제 (Synchronous)

```
Master: 쓰기 완료 → 모든 Slave에 적용 완료 확인 → 응답
    │
    ├── 장점: 데이터 완벽 일관성
    └── 단점: 매우 느림, 실무에서 거의 사용 안 함
```

### 방식 비교

|항목|비동기|반동기|동기|
|---|---|---|---|
|**쓰기 성능**|빠름|약간 느림|매우 느림|
|**데이터 안전성**|유실 가능|거의 안전|완벽|
|**Slave 장애 영향**|없음|타임아웃 후 비동기 전환|전체 멈춤|
|**실무 사용**|가장 많이 사용|MySQL에서 지원|거의 안 사용|

## Replication 토폴로지

### Master-Slave (가장 기본)

```
         Master (R/W)
        ╱    │    ╲
   Slave1  Slave2  Slave3  (Read Only)
```

### Master-Master (양방향)

```
   Master1 (R/W) ←──복제──→ Master2 (R/W)
       │                        │
   Slave1, 2               Slave3, 4
```

|장점|단점|
|---|---|
|양쪽에서 쓰기 가능|충돌 가능 (같은 데이터 동시 수정)|
|한쪽 장애 시 다른 쪽이 계속|충돌 해결 로직 필요|

### 체인 복제 (Cascading)

```
Master → Slave1 → Slave2 → Slave3

장점: Master 부하 감소 (Slave1만 Master와 통신)
단점: 복제 지연 누적
```

## Replication Lag (복제 지연)

Master와 Slave 사이의 데이터 차이가 발생하는 시간입니다.

```
Master: INSERT INTO orders VALUES (1001, ...)  ← 10:00:00
Slave:  아직 반영 안 됨                           ← 10:00:00
Slave:  INSERT INTO orders VALUES (1001, ...)  ← 10:00:02
                                                   ↑
                                              2초 Replication Lag
```

```
[Lag로 인한 문제 상황]

① 사용자가 글 작성 → Master에 INSERT
② 즉시 "내 글 목록" 조회 → Slave에서 SELECT
③ 방금 쓴 글이 안 보임! (Slave에 아직 반영 안 됨)
```

|해결 방법|설명|
|---|---|
|**쓰기 후 읽기 Master 전환**|방금 쓴 사용자의 읽기를 일시적으로 Master에서 처리|
|**강제 동기화 대기**|Slave가 특정 로그 위치까지 적용될 때까지 대기|
|**반동기 복제 사용**|최소 1개 Slave 확인 후 응답|
|**클라이언트 타임스탬프**|마지막 쓰기 시간 기록, Lag 내이면 Master에서 읽기|

## Failover (장애 조치)

```
[Master 장애 발생 시]

정상 상태:
  Master (R/W) → Slave1, Slave2, Slave3

Master 다운:
  Master (✕) → Slave1, Slave2, Slave3

Failover 실행:
  ┌──────────────────────────────────┐
  │ ① 가장 최신 데이터를 가진 Slave 선택 │
  │ ② 해당 Slave를 Master로 승격       │
  │ ③ 나머지 Slave가 새 Master를 바라봄 │
  │ ④ 애플리케이션 연결 정보 변경        │
  └──────────────────────────────────┘

Failover 완료:
  Slave1 → 새 Master (R/W)
  Slave2, Slave3 → 새 Master를 복제
```

## Java (Spring Boot) 설정 예시

```java
// 읽기/쓰기 분리를 위한 DataSource 설정

@Configuration
public class DataSourceConfig {

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.master")
    public DataSource masterDataSource() {
        return DataSourceBuilder.create().build();
    }

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.slave")
    public DataSource slaveDataSource() {
        return DataSourceBuilder.create().build();
    }

    @Bean
    public DataSource routingDataSource() {
        ReplicationRoutingDataSource routingDataSource = new ReplicationRoutingDataSource();

        Map<Object, Object> targetDataSources = new HashMap<>();
        targetDataSources.put("master", masterDataSource());
        targetDataSources.put("slave", slaveDataSource());

        routingDataSource.setTargetDataSources(targetDataSources);
        routingDataSource.setDefaultTargetDataSource(masterDataSource());
        return routingDataSource;
    }
}

// 트랜잭션 readOnly 여부로 라우팅
public class ReplicationRoutingDataSource extends AbstractRoutingDataSource {
    @Override
    protected Object determineCurrentLookupKey() {
        boolean isReadOnly = TransactionSynchronizationManager
                                .isCurrentTransactionReadOnly();
        return isReadOnly ? "slave" : "master";
    }
}
```

```java
// Service에서 사용
@Service
public class UserService {

    // 쓰기 → Master로 라우팅
    @Transactional
    public User createUser(UserDto dto) {
        return userRepository.save(dto.toEntity());
    }

    // 읽기 → Slave로 라우팅
    @Transactional(readOnly = true)
    public List<User> getUsers() {
        return userRepository.findAll();
    }
}
```

```yaml
# application.yml
spring:
  datasource:
    master:
      url: jdbc:mysql://master-host:3306/mydb
      username: root
      password: password
    slave:
      url: jdbc:mysql://slave-host:3306/mydb
      username: root
      password: password
```