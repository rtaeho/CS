---
title: "Outbox 패턴"
tags: [트랜잭션, MSA]
status: published
---

비즈니스 로직과 메시지 발행을 **같은 트랜잭션으로 묶어 메시지 유실을 방지**하는 패턴입니다.

## 기존 문제

```
주문 저장 (DB 트랜잭션)
→ 메시지 발행 (Kafka)
→ 메시지 발행 실패

주문은 저장됐는데 재고/결제 서비스에 알림 못함
→ 데이터 불일치 발생
```

## 해결 방법

```
메시지를 직접 발행하지 않고
→ Outbox 테이블에 저장 (같은 트랜잭션)
→ 별도 프로세스가 발행
```

## 동작 과정

```
[1단계 - 같은 트랜잭션]
BEGIN TRANSACTION
  orders 테이블에 주문 저장
  outbox 테이블에 이벤트 저장  ← 메시지 대신 DB에 저장
COMMIT
→ 둘 다 성공 or 둘 다 실패 (원자성 보장) O

[2단계 - 별도 프로세스]
Outbox 테이블 조회
→ Kafka 등으로 메시지 발행
→ 발행 완료 후 Outbox에서 삭제 (or 상태 변경)
```

## Outbox 테이블 구조

```sql
CREATE TABLE outbox (
    id          BIGINT PRIMARY KEY,
    aggregate   VARCHAR(50),   -- 어떤 도메인 (ORDER, PAYMENT 등)
    payload     JSON,          -- 메시지 내용
    status      VARCHAR(20),   -- PENDING, PUBLISHED
    created_at  TIMESTAMP
);
```

## Java 예시

```java
@Transactional
public void createOrder(OrderRequest request) {
    // 1. 주문 저장
    Order order = orderRepository.save(new Order(request));

    // 2. Outbox에 이벤트 저장 (같은 트랜잭션)
    outboxRepository.save(OutboxEvent.builder()
        .aggregate("ORDER")
        .payload(objectMapper.writeValueAsString(order))
        .status(OutboxStatus.PENDING)
        .build());
    // 트랜잭션 커밋 시 둘 다 저장 O
}

// 별도 스케줄러 or CDC
@Scheduled(fixedDelay = 1000)
public void publishPendingEvents() {
    outboxRepository.findByStatus(OutboxStatus.PENDING)
        .forEach(event -> {
            kafkaTemplate.send("order-topic", event.getPayload());
            event.setStatus(OutboxStatus.PUBLISHED);
            outboxRepository.save(event);
        });
}
```

## Outbox 발행 방법 2가지

```
1. Polling
   스케줄러가 주기적으로 Outbox 조회 후 발행
   → 구현 간단, 실시간성 낮음

2. CDC (Debezium)
   Outbox 테이블 변경을 CDC가 감지 후 발행
   → 실시간성 높음, 인프라 복잡
```

## 장단점

|장점|단점|
|---|---|
|메시지 유실 방지|Outbox 테이블 관리 필요|
|트랜잭션 일관성 보장|구현 복잡도 증가|
|At-Least-Once 보장|중복 발행 가능 (멱등성 필요)|

## 중복 발행 문제

```
Outbox → 발행 성공
→ 상태 변경 전 장애 발생
→ 재시도 시 중복 발행

해결: Consumer가 멱등성 보장
→ 같은 메시지 여러 번 받아도 한 번만 처리
→ 메시지 ID로 중복 체크
```

> Outbox 패턴은 **메시지 유실 없이 트랜잭션 일관성을 보장**하는 핵심 패턴으로, 마이크로서비스에서 이벤트 드리븐 아키텍처를 구현할 때 널리 사용됩니다.