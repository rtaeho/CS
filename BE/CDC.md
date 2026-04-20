데이터베이스의 **변경 사항(INSERT, UPDATE, DELETE)을 실시간으로 감지하여 다른 시스템에 전달**하는 기술입니다.

## 핵심 개념

```
DB 변경 발생
→ CDC가 변경 감지
→ 다른 시스템에 전달

애플리케이션 코드 수정 없이
DB 레벨에서 변경 사항 캡처 ✅
```

## 동작 방식 (DB 트랜잭션 로그 기반)

```
DB는 모든 변경사항을 트랜잭션 로그에 기록
(MySQL: Binary Log, PostgreSQL: WAL)

CDC 도구가 트랜잭션 로그를 읽어
→ 변경 이벤트 생성
→ Kafka 등 메시징 시스템으로 전달
```

## Polling vs CDC

||Polling|CDC|
|---|---|---|
|**감지 방식**|주기적 DB 조회|트랜잭션 로그 읽기|
|**실시간성**|낮음 (폴링 주기)|높음 (거의 실시간)|
|**DB 부하**|높음|낮음|
|**코드 수정**|필요|불필요|

## 대표 도구 - Debezium

```
오픈소스 CDC 플랫폼
MySQL, PostgreSQL, MongoDB 등 지원
Kafka와 연동하여 변경 이벤트 스트리밍
```

```java
// Debezium 설정 예시
{
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.hostname": "localhost",
    "database.port": "3306",
    "database.user": "debezium",
    "database.password": "password",
    "database.server.name": "mydb",
    "table.include.list": "mydb.orders"
}
// orders 테이블 변경 시 자동으로 Kafka로 이벤트 전송
```

## 이벤트 구조

```json
{
  "op": "u",          // u: update, c: create, d: delete
  "before": {
    "id": 1,
    "status": "PENDING"
  },
  "after": {
    "id": 1,
    "status": "DONE"   // 변경된 값
  },
  "ts_ms": 1234567890
}
```

## 활용 사례

|사례|설명|
|---|---|
|**캐시 동기화**|DB 변경 시 Redis 캐시 자동 갱신|
|**검색 엔진 동기화**|DB 변경 시 Elasticsearch 자동 반영|
|**마이크로서비스 연동**|서비스 간 데이터 동기화|
|**감사 로그**|모든 데이터 변경 이력 추적|
|**데이터 복제**|다른 DB로 실시간 복제|

## Outbox 패턴 + CDC

```
Outbox 패턴의 폴링 문제를 CDC로 해결

1. 비즈니스 로직 + Outbox 테이블 저장 (트랜잭션)
2. CDC가 Outbox 테이블 변경 감지
3. Kafka로 자동 전달
→ 폴링 없이 실시간 이벤트 발행 ✅
```

> CDC는 **애플리케이션 코드 변경 없이 DB 변경을 실시간으로 다른 시스템에 전파**할 수 있어, 마이크로서비스 간 데이터 동기화와 이벤트 드리븐 아키텍처 구현에 매우 유용합니다.