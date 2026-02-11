[[멱등성]](Idempotent)이란 **동일한 요청을 한 번 보내든 여러 번 보내든 서버의 리소스 상태가 동일하게 유지되는 성질**이며, HTTP 스펙에서 각 메서드의 멱등성 보장 여부를 명시하고 있습니다.

## 핵심 개념

```
[주의: "응답이 같다"가 아니라 "서버 상태가 같다"]

DELETE /members/1 → 200 OK (삭제됨)
DELETE /members/1 → 404 Not Found (이미 없음)

→ 응답 코드는 다르지만
→ "members/1이 존재하지 않는 상태"는 동일
→ 멱등하다 ✅
```

## HTTP Method별 멱등성

|Method|멱등|안전|이유|
|---|---|---|---|
|**GET**|✅|✅|조회만 수행, 서버 상태 변경 없음|
|**HEAD**|✅|✅|GET과 동일하나 본문 없음|
|**OPTIONS**|✅|✅|서버 정보 확인만|
|**PUT**|✅|❌|같은 데이터로 전체 교체 → 결과 항상 동일|
|**DELETE**|✅|❌|이미 삭제된 리소스 재삭제해도 상태 동일|
|**POST**|❌|❌|호출할 때마다 새 리소스 생성|
|**PATCH**|❌|❌|구현에 따라 결과가 달라질 수 있음|

```
안전(Safe):   서버 상태를 변경하지 않음 (GET, HEAD, OPTIONS)
멱등(Idempotent): 여러 번 수행해도 결과 동일 (GET, HEAD, OPTIONS, PUT, DELETE)

→ 안전하면 반드시 멱등하지만, 멱등하다고 반드시 안전하지는 않음
   (DELETE는 멱등하지만 서버 상태를 변경하므로 안전하지 않음)
```

## 각 Method별 상세 설명

### GET — 멱등 ✅

```
GET /members/1 → {id: 1, name: "홍길동"}
GET /members/1 → {id: 1, name: "홍길동"}
GET /members/1 → {id: 1, name: "홍길동"}

→ 몇 번을 호출해도 서버 상태 변화 없음
```

### PUT — 멱등 ✅

```
PUT /members/1 {name: "김철수", email: "kim@test.com"}
→ {id: 1, name: "김철수", email: "kim@test.com"}

PUT /members/1 {name: "김철수", email: "kim@test.com"}
→ {id: 1, name: "김철수", email: "kim@test.com"}

→ 같은 데이터로 전체 교체 → 몇 번 해도 결과 동일
```

### DELETE — 멱등 ✅

```
DELETE /members/1 → 200 OK (삭제됨)
DELETE /members/1 → 404 Not Found (이미 없음)
DELETE /members/1 → 404 Not Found (이미 없음)

→ 응답은 다르지만 서버 상태는 "members/1이 없는 상태"로 동일
```

### POST — 멱등 ❌

```
POST /members {name: "홍길동"} → 생성됨 (id: 1)
POST /members {name: "홍길동"} → 생성됨 (id: 2)
POST /members {name: "홍길동"} → 생성됨 (id: 3)

→ 호출할 때마다 새로운 리소스가 생성 → 서버 상태가 계속 변함
```

### PATCH — 멱등 ❌

```
[멱등한 PATCH — 절대값 수정]
PATCH /members/1 {name: "김철수"}
PATCH /members/1 {name: "김철수"}
→ 결과 동일 → 이 경우는 멱등

[멱등하지 않은 PATCH — 상대값 수정]
PATCH /accounts/1 {operation: "add", amount: 1000}
→ 잔액: 10,000 → 11,000

PATCH /accounts/1 {operation: "add", amount: 1000}
→ 잔액: 11,000 → 12,000

→ 호출할 때마다 잔액이 증가 → 서버 상태가 변함 → 멱등하지 않음
```

HTTP 스펙은 PATCH의 멱등성을 **보장하지 않습니다.** 구현에 따라 멱등할 수도, 아닐 수도 있기 때문입니다.

## 멱등성이 중요한 이유 — 네트워크 재시도

```
[네트워크 장애 시나리오]
클라이언트 → 서버: 요청 전송
서버: 정상 처리 완료
서버 → 클라이언트: 응답 전송 중 네트워크 끊김
클라이언트: 응답 못 받음 → "성공? 실패?" → 재시도할까?
```

```
[멱등한 요청 — 안전하게 재시도 가능]
PUT /members/1 {name: "김철수"} → (응답 유실) → 재시도
→ 같은 데이터로 덮어쓰기 → 결과 동일 → 문제 없음 ✅

DELETE /orders/1 → (응답 유실) → 재시도
→ 이미 삭제됨 → 상태 동일 → 문제 없음 ✅

[멱등하지 않은 요청 — 재시도 위험]
POST /orders {상품: A, 수량: 1} → (응답 유실) → 재시도
→ 주문이 2건 생성됨 → 중복 주문 발생 ❌

POST /payments {금액: 50000} → (응답 유실) → 재시도
→ 결제가 2번 됨 → 이중 결제 ❌
```

## POST의 멱등성 보장 방법 — 멱등키 패턴

```java
@PostMapping("/orders")
public ResponseEntity<OrderResponse> createOrder(
        @RequestHeader("Idempotency-Key") String idempotencyKey,
        @RequestBody OrderRequest request) {

    // 이미 처리된 요청인지 확인
    Optional<OrderResponse> existing = orderService.findByIdempotencyKey(idempotencyKey);
    if (existing.isPresent()) {
        return ResponseEntity.ok(existing.get());  // 이전 결과 그대로 반환
    }

    // 신규 주문 생성
    OrderResponse order = orderService.create(request, idempotencyKey);
    return ResponseEntity.status(HttpStatus.CREATED).body(order);
}
```

```http
// 최초 요청
POST /orders HTTP/1.1
Idempotency-Key: 550e8400-e29b-41d4-a716
Content-Type: application/json

{"productId": 1, "quantity": 1}

HTTP/1.1 201 Created
{"orderId": 100, "status": "CREATED"}

// 네트워크 장애로 응답 유실 → 재시도 (같은 멱등키)
POST /orders HTTP/1.1
Idempotency-Key: 550e8400-e29b-41d4-a716
Content-Type: application/json

{"productId": 1, "quantity": 1}

HTTP/1.1 200 OK
{"orderId": 100, "status": "CREATED"}  ← 새로 생성하지 않고 이전 결과 반환 ✅
```

```java
// 멱등키 저장소 — Redis로 구현
@Service
@RequiredArgsConstructor
public class IdempotencyService {

    private final RedisTemplate<String, String> redisTemplate;

    public boolean isDuplicate(String key) {
        return Boolean.TRUE.equals(redisTemplate.hasKey("idempotency:" + key));
    }

    public void save(String key, Object result, Duration ttl) {
        redisTemplate.opsForValue().set(
                "idempotency:" + key,
                objectMapper.writeValueAsString(result),
                ttl
        );
    }
}
```

## 실무에서 멱등성이 적용되는 곳

|영역|활용|
|---|---|
|**로드밸런서/프록시**|멱등한 요청(GET, PUT, DELETE)은 실패 시 자동 재시도 가능|
|**결제 시스템**|멱등키로 이중 결제 방지|
|**메시지 큐**|동일 메시지가 여러 번 소비돼도 결과 동일하게 보장 (Exactly-once 대신 At-least-once + 멱등성)|
|**API 게이트웨이**|5xx 에러 시 멱등한 요청만 자동 재시도|
|**분산 시스템**|네트워크 파티션 복구 후 재처리 시 멱등성 보장 필요|

## 면접 포인트

- 멱등성은 **"응답이 같다"가 아니라 "서버의 리소스 상태가 같다"**는 의미이며, DELETE는 응답 코드가 달라져도 멱등합니다.
- 멱등성의 실무적 가치는 **네트워크 장애 시 재시도 안전성**입니다. 로드밸런서, API 게이트웨이 등은 멱등한 메서드에 한해 자동 재시도 정책을 적용할 수 있습니다.
- POST는 멱등하지 않으므로 결제, 주문 같은 중요 로직에서는 **멱등키(Idempotency Key) 패턴**으로 중복 처리를 방지해야 하며, 이는 PG사 연동이나 금융 시스템에서 필수적인 설계 패턴입니다.
- PATCH는 구현에 따라 멱등할 수도 아닐 수도 있으므로, HTTP 스펙에서 멱등을 보장하지 않습니다.