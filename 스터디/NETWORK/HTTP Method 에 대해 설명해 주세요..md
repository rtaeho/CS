HTTP Method는 클라이언트가 서버에 요청을 보낼 때 **해당 리소스에 대해 수행하고자 하는 동작을 나타내는 방법**입니다.

## 주요 HTTP Method

| Method                | 역할                         | 요청 본문    | 멱등성 | 안전성 |
| --------------------- | -------------------------- | -------- | --- | --- |
| **GET**               | 리소스 조회                     | 없음       | ✅   | ✅   |
| **POST**              | 리소스 생성 / 처리 요청             | 있음       | ❌   | ❌   |
| **PUT**               | 리소스 전체 교체                  | 있음       | ✅   | ❌   |
| **PATCH**             | 리소스 부분 수정                  | 있음       | ❌   | ❌   |
| **DELETE**            | 리소스 삭제                     | 없음 또는 있음 | ✅   | ❌   |
| **HEAD**              | GET과 동일하지만 응답 본문 없이 헤더만 반환 | 없음       | ✅   | ✅   |
| **[[OPTIONS(http)]]** | 서버가 지원하는 메서드 확인            | 없음       | ✅   | ✅   |

## 각 Method 상세

### GET — 리소스 조회

```http
GET /members/1 HTTP/1.1

HTTP/1.1 200 OK
{"id": 1, "name": "홍길동", "email": "hong@test.com"}
```

```java
@GetMapping("/members/{id}")
public ResponseEntity<MemberResponse> getMember(@PathVariable Long id) {
    return ResponseEntity.ok(memberService.findById(id));  // 200
}
```

### POST — 리소스 생성

```http
POST /members HTTP/1.1
Content-Type: application/json

{"name": "홍길동", "email": "hong@test.com"}

HTTP/1.1 201 Created
Location: /members/1
{"id": 1, "name": "홍길동", "email": "hong@test.com"}
```

```java
@PostMapping("/members")
public ResponseEntity<MemberResponse> createMember(@RequestBody MemberRequest request) {
    MemberResponse member = memberService.create(request);
    URI location = URI.create("/members/" + member.getId());
    return ResponseEntity.created(location).body(member);  // 201
}
```

### PUT — 리소스 전체 교체

```http
PUT /members/1 HTTP/1.1
Content-Type: application/json

{"name": "김철수", "email": "kim@test.com"}

HTTP/1.1 200 OK
{"id": 1, "name": "김철수", "email": "kim@test.com"}
```

```java
@PutMapping("/members/{id}")
public ResponseEntity<MemberResponse> updateMember(@PathVariable Long id,
                                                     @RequestBody MemberRequest request) {
    return ResponseEntity.ok(memberService.update(id, request));  // 200
}
```

### PATCH — 리소스 부분 수정

```http
PATCH /members/1 HTTP/1.1
Content-Type: application/json

{"email": "new@test.com"}

HTTP/1.1 200 OK
{"id": 1, "name": "홍길동", "email": "new@test.com"}
```

```java
@PatchMapping("/members/{id}")
public ResponseEntity<MemberResponse> patchMember(@PathVariable Long id,
                                                    @RequestBody MemberPatchRequest request) {
    return ResponseEntity.ok(memberService.patch(id, request));  // 200
}
```

### DELETE — 리소스 삭제

```http
DELETE /members/1 HTTP/1.1

HTTP/1.1 204 No Content
```

```java
@DeleteMapping("/members/{id}")
public ResponseEntity<Void> deleteMember(@PathVariable Long id) {
    memberService.delete(id);
    return ResponseEntity.noContent().build();  // 204
}
```

## 멱등성과 안전성

### [[멱등성]] (Idempotent)

**같은 요청을 여러 번 보내도 결과가 동일**한 성질입니다.

```
[GET — 멱등 ✅]
GET /members/1 → 홍길동
GET /members/1 → 홍길동   ← 몇 번을 해도 같은 결과

[DELETE — 멱등 ✅]
DELETE /members/1 → 삭제됨
DELETE /members/1 → 이미 없음 (결과적으로 상태 동일)

[POST — 멱등 ❌]
POST /members → 회원 생성 (id: 1)
POST /members → 회원 생성 (id: 2)  ← 호출할 때마다 새 리소스 생성
```

### 안전성 (Safe)

요청이 **서버의 리소스 상태를 변경하지 않는** 성질입니다.

```
GET    → 조회만 함 → 서버 상태 변경 없음 → 안전 ✅
POST   → 새 리소스 생성 → 서버 상태 변경 → 안전 ❌
DELETE → 리소스 삭제 → 서버 상태 변경 → 안전 ❌
```

### HEAD와 OPTIONS

```http
// HEAD — 본문 없이 헤더만 확인
// 파일 크기나 존재 여부 확인 시 유용
HEAD /files/report.pdf HTTP/1.1

HTTP/1.1 200 OK
Content-Length: 2048000
Content-Type: application/pdf
// 본문 없음
```

```http
// OPTIONS — 허용된 메서드 확인
// CORS 프리플라이트 요청에서 주로 사용
OPTIONS /members HTTP/1.1

HTTP/1.1 200 OK
Allow: GET, POST, PUT, DELETE, OPTIONS
```

## CRUD와 HTTP Method 매핑

| CRUD        | HTTP Method | URI 예시            | 응답 코드 |
| ----------- | ----------- | ----------------- | ----- |
| Create      | POST        | POST /members     | 201   |
| Read        | GET         | GET /members/1    | 200   |
| Update (전체) | PUT         | PUT /members/1    | 200   |
| Update (부분) | PATCH       | PATCH /members/1  | 200   |
| Delete      | DELETE      | DELETE /members/1 | 204   |

## 면접 포인트

- 각 Method의 **의미를 지켜서 사용하는 것이 RESTful API 설계의 핵심**이며, 예를 들어 조회에 POST를 사용하거나 삭제에 GET을 사용하는 것은 안티패턴입니다.
- 멱등성은 실무에서 **네트워크 장애 시 재시도 정책**과 직결됩니다. 멱등한 GET, PUT, DELETE는 안전하게 재시도할 수 있지만, POST는 중복 생성 위험이 있어 별도의 중복 방지 로직이 필요합니다.