POST는 **새로운 리소스를 생성**, PUT은 **리소스 전체를 교체**, PATCH는 **리소스의 일부만 수정**하는 메서드이며, 멱등성과 리소스 식별 방식에서 핵심적인 차이가 있습니다.

## 핵심 차이

| 항목               | POST           | PUT            | PATCH     |
| ---------------- | -------------- | -------------- | --------- |
| **목적**           | 리소스 생성 / 처리 요청 | 리소스 전체 교체      | 리소스 부분 수정 |
| **멱등성**          | ❌              | ✅              | ❌         |
| **리소스 URI**      | 서버가 결정         | 클라이언트가 지정      | 클라이언트가 지정 |
| **대상 리소스 존재 여부** | 없으면 생성         | 없으면 생성, 있으면 교체 | 없으면 에러    |
| **누락 필드 처리**     | —              | null/기본값으로 초기화 | 기존 값 유지   |

## [[리소스 URI 결정]] 방식

```http
// POST — 서버가 리소스 URI를 결정
POST /members HTTP/1.1
{"name": "홍길동", "email": "hong@test.com"}

HTTP/1.1 201 Created
Location: /members/1    ← 서버가 id=1 부여

// PUT — 클라이언트가 리소스 URI를 지정
PUT /members/1 HTTP/1.1
{"name": "홍길동", "email": "hong@test.com"}

HTTP/1.1 200 OK         ← 클라이언트가 /members/1로 지정

// PATCH — 클라이언트가 리소스 URI를 지정
PATCH /members/1 HTTP/1.1
{"email": "new@test.com"}

HTTP/1.1 200 OK         ← 클라이언트가 /members/1로 지정
```

## PUT vs PATCH — 수정 방식 차이

```
[기존 데이터]
{
    "id": 1,
    "name": "홍길동",
    "email": "hong@test.com",
    "age": 25,
    "phone": "010-1234-5678"
}

[PUT — 전체 교체]
PUT /members/1
{"name": "홍길동", "email": "new@test.com"}

결과:
{
    "id": 1,
    "name": "홍길동",
    "email": "new@test.com",
    "age": null,           ← 보내지 않은 필드 → null
    "phone": null           ← 보내지 않은 필드 → null
}

[PATCH — 부분 수정]
PATCH /members/1
{"email": "new@test.com"}

결과:
{
    "id": 1,
    "name": "홍길동",
    "email": "new@test.com",
    "age": 25,              ← 기존 값 유지
    "phone": "010-1234-5678" ← 기존 값 유지
}
```

## Spring 구현 예시

### POST — 생성

```java
@PostMapping("/members")
public ResponseEntity<MemberResponse> createMember(
        @RequestBody MemberCreateRequest request) {

    MemberResponse member = memberService.create(request);

    URI location = URI.create("/members/" + member.getId());
    return ResponseEntity.created(location).body(member);  // 201
}
```

### PUT — 전체 교체

```java
@PutMapping("/members/{id}")
public ResponseEntity<MemberResponse> updateMember(
        @PathVariable Long id,
        @RequestBody MemberUpdateRequest request) {

    // 모든 필드를 덮어쓰기
    MemberResponse member = memberService.update(id, request);
    return ResponseEntity.ok(member);  // 200
}
```

```java
// Service — PUT은 모든 필드를 교체
@Transactional
public MemberResponse update(Long id, MemberUpdateRequest request) {
    Member member = memberRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("회원 없음"));

    // 전체 필드를 새 값으로 교체 (보내지 않은 필드는 null)
    member.setName(request.getName());
    member.setEmail(request.getEmail());
    member.setAge(request.getAge());
    member.setPhone(request.getPhone());

    return new MemberResponse(member);
}
```

### PATCH — 부분 수정

```java
@PatchMapping("/members/{id}")
public ResponseEntity<MemberResponse> patchMember(
        @PathVariable Long id,
        @RequestBody MemberPatchRequest request) {

    MemberResponse member = memberService.patch(id, request);
    return ResponseEntity.ok(member);  // 200
}
```

```java
// Service — PATCH는 전달된 필드만 수정
@Transactional
public MemberResponse patch(Long id, MemberPatchRequest request) {
    Member member = memberRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("회원 없음"));

    // null이 아닌 필드만 업데이트
    if (request.getName() != null) {
        member.setName(request.getName());
    }
    if (request.getEmail() != null) {
        member.setEmail(request.getEmail());
    }
    if (request.getAge() != null) {
        member.setAge(request.getAge());
    }
    if (request.getPhone() != null) {
        member.setPhone(request.getPhone());
    }

    return new MemberResponse(member);
}
```

## [[멱등성]] 차이

### POST — 멱등하지 않음 ❌

```
POST /members {name: "홍길동"} → 생성 (id: 1)
POST /members {name: "홍길동"} → 생성 (id: 2)
POST /members {name: "홍길동"} → 생성 (id: 3)

→ 호출할 때마다 새 리소스 생성 → 서버 상태 변경
```

### PUT — 멱등 ✅

```
PUT /members/1 {name: "김철수", email: "kim@test.com"}
→ {id: 1, name: "김철수", email: "kim@test.com"}

PUT /members/1 {name: "김철수", email: "kim@test.com"}
→ {id: 1, name: "김철수", email: "kim@test.com"}

→ 같은 데이터로 전체 교체 → 몇 번 해도 결과 동일
```

### PATCH — 멱등하지 않음 ❌

```
[멱등한 경우 — 절대값 수정]
PATCH /members/1 {name: "김철수"}
PATCH /members/1 {name: "김철수"}
→ 결과 동일 → 이 경우는 멱등

[멱등하지 않은 경우 — 상대값 수정]
PATCH /accounts/1 {operation: "add", amount: 1000}
→ 잔액: 10,000 → 11,000

PATCH /accounts/1 {operation: "add", amount: 1000}
→ 잔액: 11,000 → 12,000

→ 호출할 때마다 결과 변경 → 멱등하지 않음
```

## PUT의 생성 기능 — POST와의 차이

PUT도 리소스가 없으면 생성할 수 있습니다. POST와의 차이는 **URI를 누가 결정하는가**입니다.

```
[POST — 서버가 URI 결정]
POST /members
→ 서버가 id=1 부여 → /members/1 생성

[PUT — 클라이언트가 URI 지정]
PUT /members/1
→ /members/1이 없으면 생성, 있으면 교체
```

```java
// PUT으로 생성 또는 교체
@PutMapping("/members/{id}")
public ResponseEntity<MemberResponse> createOrUpdate(
        @PathVariable Long id,
        @RequestBody MemberUpdateRequest request) {

    boolean exists = memberRepository.existsById(id);
    MemberResponse member = memberService.createOrUpdate(id, request);

    if (exists) {
        return ResponseEntity.ok(member);                              // 200 — 교체
    } else {
        URI location = URI.create("/members/" + member.getId());
        return ResponseEntity.created(location).body(member);          // 201 — 생성
    }
}
```

## 리소스가 없는 경우 동작 비교

|메서드|리소스 존재|리소스 없음|
|---|---|---|
|**POST**|보통 409 Conflict (중복)|새로 생성 → 201|
|**PUT**|전체 교체 → 200|새로 생성 → 201|
|**PATCH**|부분 수정 → 200|404 Not Found (수정 대상 없음)|

## 실무에서의 사용 패턴

```
[일반적인 CRUD API]
POST   /members          → 회원 생성
GET    /members/{id}     → 회원 조회
PUT    /members/{id}     → 회원 전체 수정 (프로필 전체 폼 저장)
PATCH  /members/{id}     → 회원 부분 수정 (닉네임만 변경, 알림 설정만 변경)
DELETE /members/{id}     → 회원 삭제

[실무에서의 현실]
- PUT과 PATCH를 엄격히 구분하지 않고 PATCH로 통일하는 경우도 많음
- PUT의 "보내지 않은 필드를 null로 초기화" 동작이
  의도치 않은 데이터 손실을 유발할 수 있어 PATCH를 선호하는 추세
```

## 전체 비교 요약

```
POST                        PUT                         PATCH
├─ 리소스 생성               ├─ 리소스 전체 교체           ├─ 리소스 부분 수정
├─ URI: 서버가 결정          ├─ URI: 클라이언트가 지정     ├─ URI: 클라이언트가 지정
├─ 멱등 ❌                  ├─ 멱등 ✅                   ├─ 멱등 ❌
├─ 없으면 생성              ├─ 없으면 생성, 있으면 교체    ├─ 없으면 에러
├─ 재시도 위험 (중복 생성)   ├─ 재시도 안전               ├─ 구현에 따라 다름
└─ POST /members            └─ PUT /members/1            └─ PATCH /members/1
```

## 면접 포인트

- POST와 PUT의 핵심 차이는 **리소스 URI를 누가 결정하는가**입니다. POST는 서버가, PUT은 클라이언트가 결정합니다.
- PUT과 PATCH의 핵심 차이는 **전체 교체 vs 부분 수정**이며, PUT은 보내지 않은 필드를 null로 초기화하므로 의도치 않은 데이터 손실에 주의해야 합니다.
- PUT이 멱등하고 PATCH가 멱등하지 않은 이유는, PUT은 항상 같은 데이터로 전체를 덮어쓰지만 PATCH는 **상대적 변경(금액 증가 등)이 가능**하여 구현에 따라 결과가 달라질 수 있기 때문입니다.