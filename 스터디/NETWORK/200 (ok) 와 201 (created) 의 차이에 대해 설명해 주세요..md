200은 **요청이 성공적으로 처리되었음**을 의미하고, 201은 **요청이 성공하여 새로운 리소스가 생성되었음**을 의미하는 보다 구체적인 성공 응답입니다.

## 핵심 차이

```
200 OK:      "요청 잘 처리했어"         → 범용적 성공
201 Created: "요청 잘 처리해서 새로 만들었어" → 리소스 생성 성공
```

|항목|200 OK|201 Created|
|---|---|---|
|**의미**|요청 성공 (일반적)|새 리소스 생성 성공|
|**사용 메서드**|GET, PUT, PATCH, DELETE 등|주로 POST (또는 PUT)|
|**Location 헤더**|보통 포함하지 않음|생성된 리소스의 URI 포함 권장|
|**응답 본문**|요청에 대한 결과 데이터|생성된 리소스 데이터|

## [[HTTP]] 응답 예시

```http
// 200 OK — 조회 성공
GET /members/1 HTTP/1.1

HTTP/1.1 200 OK
Content-Type: application/json

{
    "id": 1,
    "name": "홍길동",
    "email": "hong@test.com"
}
```

```http
// 201 Created — 생성 성공
POST /members HTTP/1.1
Content-Type: application/json

{"name": "홍길동", "email": "hong@test.com"}

HTTP/1.1 201 Created
Location: /members/1          ← 생성된 리소스의 URI
Content-Type: application/json

{
    "id": 1,
    "name": "홍길동",
    "email": "hong@test.com"
}
```

## Spring 구현 예시

```java
// 200 OK — 조회
@GetMapping("/members/{id}")
public ResponseEntity<MemberResponse> getMember(@PathVariable Long id) {
    MemberResponse member = memberService.findById(id);
    return ResponseEntity.ok(member);  // 200
}

// 201 Created — 생성
@PostMapping("/members")
public ResponseEntity<MemberResponse> createMember(@RequestBody MemberRequest request) {
    MemberResponse member = memberService.create(request);

    URI location = URI.create("/members/" + member.getId());

    return ResponseEntity
            .created(location)  // 201 + Location 헤더 자동 설정
            .body(member);
}
```

## 언제 어떤 코드를 쓰는가

|HTTP 메서드|동작|권장 응답 코드|
|---|---|---|
|**GET**|리소스 조회|200 OK|
|**POST**|리소스 생성|**201 Created**|
|**PUT**|리소스 전체 수정|200 OK|
|**PUT**|리소스가 없어서 새로 생성|**201 Created**|
|**PATCH**|리소스 부분 수정|200 OK|
|**DELETE**|리소스 삭제|200 OK 또는 204 No Content|

### PUT의 경우 — 상황에 따라 달라짐

```java
@PutMapping("/members/{id}")
public ResponseEntity<MemberResponse> updateMember(@PathVariable Long id,
                                                     @RequestBody MemberRequest request) {
    boolean exists = memberService.exists(id);
    MemberResponse member = memberService.createOrUpdate(id, request);

    if (exists) {
        return ResponseEntity.ok(member);                              // 200 — 기존 리소스 수정
    } else {
        URI location = URI.create("/members/" + member.getId());
        return ResponseEntity.created(location).body(member);          // 201 — 새 리소스 생성
    }
}
```

## 201 응답 시 Location 헤더의 역할

```http
HTTP/1.1 201 Created
Location: /members/1
```

Location 헤더는 **생성된 리소스에 접근할 수 있는 URI**를 알려줍니다. 클라이언트는 이 URI로 후속 요청을 보낼 수 있습니다.

```
1. POST /members → 201 Created, Location: /members/1
2. GET /members/1 → 200 OK (생성된 리소스 조회)
```

## 200으로 통일하면 안 되나?

동작상으로는 문제없지만, **REST API 설계 관점에서 권장하지 않습니다.**

```
[200으로 통일한 경우]
POST /members → 200 OK
→ 클라이언트: 생성된 건지, 기존 데이터를 반환한 건지 구분 불가

[201을 사용한 경우]
POST /members → 201 Created
→ 클라이언트: 새 리소스가 생성되었음을 명확히 인지
→ Location 헤더로 생성된 리소스 위치도 파악 가능
```

|관점|200 통일|201 구분 사용|
|---|---|---|
|**의미 전달**|모호|명확|
|**클라이언트 처리**|본문을 파싱해야 판단 가능|상태 코드만으로 판단 가능|
|**REST 성숙도**|Level 1~2|Level 2 이상|
|**API 문서화**|설명 필요|코드 자체가 문서 역할|

## 면접 포인트

- 200은 범용적 성공, 201은 **리소스 생성에 특화된 성공 응답**이며, POST 요청의 결과로 새 리소스가 만들어졌을 때 201을 사용합니다.
- 201 응답 시 **Location 헤더에 생성된 리소스의 URI를 포함**하는 것이 RESTful API의 모범 사례입니다.
- 적절한 응답 코드를 구분하여 사용하면 **클라이언트가 응답 본문을 파싱하지 않고도 상태 코드만으로 결과를 판단**할 수 있어 API의 명확성과 사용성이 높아집니다.