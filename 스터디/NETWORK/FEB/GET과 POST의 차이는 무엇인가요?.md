GET은 **서버의 리소스를 조회**하기 위한 메서드이고, POST는 **서버에 데이터를 전송하여 리소스를 생성하거나 처리를 요청**하기 위한 메서드입니다.

## 핵심 차이

| 항목            | GET                             | POST            |
| ------------- | ------------------------------- | --------------- |
| **목적**        | 리소스 조회                          | 리소스 생성 / 데이터 처리 |
| **데이터 전달**    | URL 쿼리스트링                       | 요청 본문(Body)     |
| **멱등성**       | ✅                               | ❌               |
| **안전성**       | ✅ (서버 상태 변경 없음)                 | ❌               |
| **캐싱**        | ✅ (브라우저/CDN 캐싱 가능)              | ❌               |
| **북마크**       | 가능                              | 불가능             |
| **브라우저 히스토리** | URL에 남음                         | 남지 않음           |
| **데이터 길이**    | URL 길이 제한 (브라우저마다 다름, 약 2,048자) | 제한 없음           |

## 데이터 전달 방식

```http
// GET — URL 쿼리스트링에 데이터 포함
GET /members?name=홍길동&age=25 HTTP/1.1
Host: api.example.com

→ 데이터가 URL에 노출됨
→ 브라우저 주소창, 히스토리, 서버 로그에 남음

// POST — 요청 본문에 데이터 포함
POST /members HTTP/1.1
Host: api.example.com
Content-Type: application/json

{"name": "홍길동", "age": 25}

→ 데이터가 URL에 노출되지 않음
→ 단, HTTPS가 아니면 본문도 평문 전송되므로 보안이 보장되지는 않음
```

```java
// Spring — GET
@GetMapping("/members")
public ResponseEntity<List<MemberResponse>> getMembers(
        @RequestParam String name,
        @RequestParam int age) {
    return ResponseEntity.ok(memberService.search(name, age));
}

// Spring — POST
@PostMapping("/members")
public ResponseEntity<MemberResponse> createMember(
        @RequestBody MemberRequest request) {
    MemberResponse member = memberService.create(request);
    URI location = URI.create("/members/" + member.getId());
    return ResponseEntity.created(location).body(member);
}
```

## [[캐싱]] 차이

```
[GET — 캐싱 가능 ✅]
GET /members/1 → 200 OK + Cache-Control: max-age=3600

브라우저: 1시간 동안 캐시된 응답 사용
→ 서버에 요청을 보내지 않아도 됨 → 성능 향상

CDN도 GET 응답을 캐싱하여 전 세계에 분산 가능

[POST — 캐싱 불가 ❌]
POST /members → 매번 새로운 리소스 생성
→ 이전 응답을 재사용할 수 없음
→ 브라우저, CDN 모두 캐싱하지 않음
```

```
[캐싱이 되는 이유]
GET은 멱등하고 안전하므로
→ 같은 요청에 대해 항상 같은 결과를 기대할 수 있음
→ 이전 응답을 재사용해도 안전

POST는 멱등하지 않으므로
→ 같은 요청이라도 매번 다른 결과가 나올 수 있음
→ 이전 응답을 재사용하면 위험
```

## [[멱등성]] 차이

```
[GET — 멱등 ✅]
GET /members/1 → {id: 1, name: "홍길동"}
GET /members/1 → {id: 1, name: "홍길동"}
→ 몇 번을 호출해도 서버 상태 동일

[POST — 멱등 ❌]
POST /members {name: "홍길동"} → 생성 (id: 1)
POST /members {name: "홍길동"} → 생성 (id: 2)
→ 호출할 때마다 새 리소스 생성 → 서버 상태 변경
```

이 차이 때문에 네트워크 장애 시 GET은 안전하게 재시도 가능하지만, POST는 중복 생성 위험이 있어 멱등키 등 별도 방어가 필요합니다.

## 보안 차이 — GET이 POST보다 위험한 경우

```
[GET — 민감 정보가 URL에 노출]
GET /login?username=hong&password=1234 HTTP/1.1

→ 브라우저 주소창에 표시
→ 브라우저 히스토리에 저장
→ 서버 액세스 로그에 기록: "GET /login?username=hong&password=1234"
→ Referer 헤더로 다른 사이트에 URL 전달 가능

[POST — 본문에 포함]
POST /login HTTP/1.1
Content-Type: application/json

{"username": "hong", "password": "1234"}

→ URL에 노출되지 않음
→ 서버 로그에 URL만 기록: "POST /login"
→ 단, HTTPS 없이는 본문도 평문이므로 완전한 보안은 아님
```

|노출 위치|GET|POST|
|---|---|---|
|**브라우저 주소창**|✅ 노출|❌|
|**브라우저 히스토리**|✅ 저장|❌|
|**서버 액세스 로그**|✅ URL에 포함|❌ URL만 기록|
|**Referer 헤더**|✅ 전달 가능|❌|
|**북마크**|✅ 쿼리스트링 포함|❌|

## 잘못된 사용 예시

```java
// ❌ GET으로 리소스 변경 — 안티패턴
@GetMapping("/members/1/delete")
public ResponseEntity<Void> deleteMember() {
    memberService.delete(1L);
    return ResponseEntity.ok().build();
}
// 문제점:
// 1. 웹 크롤러가 이 URL을 방문하면 데이터 삭제
// 2. 브라우저 프리패치가 실행하면 의도치 않은 삭제
// 3. GET은 안전해야 한다는 HTTP 스펙 위반

// ✅ 올바른 사용
@DeleteMapping("/members/{id}")
public ResponseEntity<Void> deleteMember(@PathVariable Long id) {
    memberService.delete(id);
    return ResponseEntity.noContent().build();
}
```

```java
// ❌ POST로 단순 조회 — 캐싱 불가
@PostMapping("/members/search")
public ResponseEntity<List<Member>> search(@RequestBody SearchRequest request) {
    return ResponseEntity.ok(memberService.search(request));
}

// ✅ GET으로 조회 — 캐싱 가능
@GetMapping("/members")
public ResponseEntity<List<Member>> search(
        @RequestParam String name,
        @RequestParam(required = false) Integer age) {
    return ResponseEntity.ok(memberService.search(name, age));
}
```

### 예외: POST로 조회하는 것이 적절한 경우

```java
// 검색 조건이 매우 복잡하여 URL 길이 제한을 초과하는 경우
// 또는 검색 조건 자체가 민감 정보를 포함하는 경우
@PostMapping("/members/search")
public ResponseEntity<List<Member>> search(@RequestBody ComplexSearchRequest request) {
    // 수십 개의 필터 조건, 중첩 객체 등
    return ResponseEntity.ok(memberService.complexSearch(request));
}
```

## 전체 비교 요약

```
GET                              POST
├─ 리소스 조회                    ├─ 리소스 생성 / 처리
├─ 데이터: URL 쿼리스트링          ├─ 데이터: 요청 본문
├─ 멱등 ✅ → 재시도 안전          ├─ 멱등 ❌ → 재시도 위험
├─ 캐싱 ✅ → 성능 유리            ├─ 캐싱 ❌
├─ URL 노출 → 민감 정보 부적합     ├─ 본문 전달 → 상대적으로 안전
└─ 데이터 길이 제한 있음           └─ 데이터 길이 제한 없음
```

## 면접 포인트

- GET과 POST의 가장 근본적인 차이는 **데이터 전달 위치가 아니라 목적과 의미(Semantics)**입니다. GET은 조회, POST는 생성/처리이며, 이 의미를 지키는 것이 RESTful API 설계의 핵심입니다.
- GET이 POST보다 보안에 취약한 것이 아니라, **민감 정보를 URL에 포함하면 안 된다**는 것이 핵심입니다. POST도 HTTPS 없이는 본문이 평문 전송되므로 진정한 보안은 HTTPS로 보장해야 합니다.
- GET은 멱등하고 캐싱이 가능하므로 **조회 API는 GET을 사용해야 캐싱, CDN, 재시도 등의 인프라 이점**을 얻을 수 있습니다.