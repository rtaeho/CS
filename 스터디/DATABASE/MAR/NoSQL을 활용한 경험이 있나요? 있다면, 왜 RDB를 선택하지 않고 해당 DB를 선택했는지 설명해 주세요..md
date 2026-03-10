RDB의 한계가 서비스 요구사항과 맞지 않을 때 NoSQL을 선택하며, 크게 **5가지 상황**으로 정리할 수 있습니다.

## 선택 기준 한눈에 보기

| 상황                | 선택    | 대표 DB              |
| ----------------- | ----- | ------------------ |
| 빠른 캐싱/세션 처리       | NoSQL | Redis              |
| 스키마가 유동적인 데이터     | NoSQL | MongoDB            |
| 대용량 트래픽, 수평 확장 필요 | NoSQL | Cassandra, MongoDB |
| 실시간 순위/카운트        | NoSQL | Redis              |
| 복잡한 관계, 정합성 중요    | RDB   | MySQL, PostgreSQL  |

## 상황별 이유

### 1. 캐싱 / 세션 관리 → Redis

```
문제: 매 요청마다 RDB 조회 시 부하 집중
이유: 
- 메모리 기반으로 마이크로초 단위 응답
- TTL(만료시간) 기능 내장
- 세션은 정합성보다 속도가 중요

ex) 로그인 세션, API 응답 캐싱, 인증 토큰
```

### 2. 비정형 / 유동적 스키마 → MongoDB

```
문제: 카테고리별로 속성이 달라 고정 스키마 적용 어려움
이유:
- 문서(Document) 구조로 자유로운 스키마
- RDB였다면 수십 개의 nullable 컬럼 or 복잡한 설계 필요

ex) 쇼핑몰 상품 (의류: 사이즈/색상, 전자: 전압/용량)
    로그, 이벤트 데이터
```

```json
// 카테고리마다 다른 구조를 자유롭게 저장
{ "category": "의류", "size": "L", "color": "black" }
{ "category": "전자", "voltage": "220V", "storage": "256GB" }
```

### 3. 대용량 트래픽 / 수평 확장 → Cassandra, MongoDB

```
문제: 트래픽 급증 시 RDB 단일 서버가 병목
이유:
- 샤딩(Sharding)으로 서버 추가만으로 확장 가능
- RDB Scale-Up은 비용 급증 + 물리적 한계 존재

ex) 글로벌 서비스, 수천만 사용자 대상 피드/타임라인
```

### 4. 실시간 랭킹 / 카운트 → Redis

```
문제: RDB로 실시간 집계 시 매번 무거운 쿼리 발생
이유:
- Redis Sorted Set으로 실시간 랭킹 O(log n) 처리
- 원자적 카운팅 (INCR) 지원

ex) 게임 실시간 순위, 좋아요 수, 조회수
```

```java
// Redis Sorted Set으로 실시간 랭킹
redisTemplate.opsForZSet().add("ranking", "userA", 1500);
redisTemplate.opsForZSet().reverseRange("ranking", 0, 9); // 상위 10명
```

### 5. 시계열 / 대용량 쓰기 → Cassandra

```
문제: RDB는 대량 INSERT 시 락 경합, 인덱스 재구성 부하
이유:
- 쓰기에 최적화된 구조 (LSM Tree)
- 시간 순서 데이터를 효율적으로 저장

ex) IoT 센서 데이터, 서버 로그, 클릭스트림
```

## 결론

```
NoSQL 선택의 핵심 기준

정합성 < 성능/가용성   → NoSQL
스키마가 자주 바뀜     → NoSQL
수평 확장이 필수       → NoSQL
단순 조회/쓰기 위주    → NoSQL

반대라면 → RDB
```

> NoSQL은 **"RDB의 엄격함을 포기하는 대신 얻는 유연성과 성능"** 입니다. 선택의 핵심은 항상 **서비스의 요구사항**이며, 대부분의 실무에서는 RDB + NoSQL을 함께 사용합니다.