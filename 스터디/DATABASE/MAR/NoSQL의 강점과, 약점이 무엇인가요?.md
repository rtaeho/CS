NoSQL은 **유연성과 확장성이 강점**이지만, **데이터 일관성과 복잡한 관계 표현이 약점**입니다.

## 강점

### 1. 유연한 스키마

```json
// 사용자마다 다른 구조 저장 가능
{ "_id": 1, "name": "kim", "age": 25 }
{ "_id": 2, "name": "lee", "age": 30, "address": "서울", "tags": ["VIP"] }
// RDB였다면 ALTER TABLE로 컬럼 추가 필요
```

### 2. 수평 확장 (Scale-Out)

```
트래픽 증가 시
RDB  → 더 좋은 서버로 교체 (비용 급증, 한계 존재)
NoSQL → 서버 추가로 부하 분산 (상대적으로 저렴)
```

### 3. 빠른 읽기/쓰기

```
Redis  : 데이터를 메모리에 저장 → 마이크로초 단위 응답
MongoDB: JOIN 없이 한 문서에서 모든 데이터 조회 가능
```

### 4. 대용량 비정형 데이터 처리

```
로그, 이벤트, IoT 센서 데이터 등
→ 스키마 없이 그냥 쌓을 수 있음
```

## 약점

### 1. 데이터 일관성 문제

```
NoSQL은 대부분 최종 일관성(Eventual Consistency) 채택

서버 A에 데이터 저장
    ↓ 복제 중 (약간의 시간 차)
서버 B에서 조회 → 이전 데이터가 조회될 수 있음 ⚠️

→ 금융, 결제 등 정합성이 중요한 도메인에 부적합
```

### 2. JOIN 미지원 → 데이터 중복

```json
// 주문마다 유저 정보를 중복 저장해야 함
{ "order_id": 1, "user_name": "kim", "user_email": "kim@.." }
{ "order_id": 2, "user_name": "kim", "user_email": "kim@.." }

// 이메일 변경 시 → 관련 문서 전부 수동 업데이트 필요 ❌
```

### 3. 트랜잭션 제한

```java
// RDB - 트랜잭션으로 묶어서 ACID 보장
@Transactional
public void transfer() {
    accountA.withdraw(1000);
    accountB.deposit(1000);  // 하나라도 실패 시 전체 롤백
}

// NoSQL - 문서 단위 원자성만 보장
// 여러 문서에 걸친 트랜잭션은 보장 어려움 ⚠️
// (MongoDB 4.0+부터 멀티 도큐먼트 트랜잭션 지원하지만 성능 비용 발생)
```

### 4. 복잡한 쿼리 어려움

```sql
-- RDB: JOIN으로 간단히 처리
SELECT u.name, COUNT(o.id)
FROM user u
JOIN orders o ON u.id = o.user_id
GROUP BY u.name;

-- NoSQL: 애플리케이션 레벨에서 직접 처리하거나
-- Aggregation Pipeline 등 복잡한 방식 사용 필요
```

## 정리

|강점|약점|
|---|---|
|유연한 스키마|데이터 중복 발생|
|수평 확장 용이|트랜잭션 제한|
|높은 쓰기/읽기 성능|복잡한 관계 표현 어려움|
|대용량 비정형 데이터|일관성 보장 어려움|

> 결국 NoSQL은 **"정합성보다 가용성과 성능"** 이 중요한 상황에서 빛을 발합니다. 반대로 데이터 무결성이 핵심인 도메인에서는 RDB가 여전히 정답입니다.