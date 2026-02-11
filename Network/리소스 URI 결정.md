 리소스 URI 결정이란 **새로 생성되는 리소스의 고유 식별 주소(URI)를 누가 정하는가**의 차이를 의미합니다.

## 핵심 개념

```
리소스 URI = 해당 리소스에 접근할 수 있는 고유 주소

예시:
/members/1   → 1번 회원의 URI
/members/2   → 2번 회원의 URI
/orders/100  → 100번 주문의 URI

이 URI를 "서버가 정하느냐" vs "클라이언트가 정하느냐"의 차이
```

## POST — 서버가 URI를 결정

```http
// 클라이언트: "회원 하나 만들어줘" (URI를 지정하지 않음)
POST /members HTTP/1.1
Content-Type: application/json

{"name": "홍길동", "email": "hong@test.com"}

// 서버: "알겠어, id=1로 만들었어" (서버가 URI 결정)
HTTP/1.1 201 Created
Location: /members/1    ← 서버가 /members/1이라는 URI를 부여

// 클라이언트는 생성 전에 이 리소스의 URI를 알 수 없음
// 서버의 응답(Location)을 받아야 비로소 알 수 있음
```

```java
@PostMapping("/members")  // 컬렉션 URI에 요청
public ResponseEntity<MemberResponse> createMember(
        @RequestBody MemberRequest request) {

    // 서버가 id를 자동 생성 (DB auto_increment 등)
    Member member = Member.builder()
            .name(request.getName())
            .email(request.getEmail())
            .build();

    Member saved = memberRepository.save(member);  // id=1 자동 부여

    URI location = URI.create("/members/" + saved.getId());
    return ResponseEntity.created(location).body(new MemberResponse(saved));
}
```

```
[POST의 흐름]
클라이언트: POST /members ← 컬렉션(목록) URI에 요청
서버: id=1 생성 → /members/1 탄생
서버: id=2 생성 → /members/2 탄생
서버: id=3 생성 → /members/3 탄생

→ 클라이언트는 "만들어달라"만 요청
→ 어떤 URI가 될지는 서버가 결정
```

## PUT — 클라이언트가 URI를 결정

```http
// 클라이언트: "/members/1에 이 데이터를 넣어줘" (URI를 직접 지정)
PUT /members/1 HTTP/1.1
Content-Type: application/json

{"name": "홍길동", "email": "hong@test.com"}

// 서버: "/members/1이 없으니 만들었어" 또는 "있으니 교체했어"
HTTP/1.1 201 Created
// 또는
HTTP/1.1 200 OK

// 클라이언트가 생성 전에 이미 URI(/members/1)를 알고 있음
```

```java
@PutMapping("/members/{id}")  // 특정 리소스 URI에 요청
public ResponseEntity<MemberResponse> createOrUpdate(
        @PathVariable Long id,    // 클라이언트가 id를 지정
        @RequestBody MemberRequest request) {

    boolean exists = memberRepository.existsById(id);

    // 클라이언트가 지정한 id로 생성 또는 교체
    Member member = Member.builder()
            .id(id)  // 클라이언트가 결정한 id 사용
            .name(request.getName())
            .email(request.getEmail())
            .build();

    memberRepository.save(member);

    if (exists) {
        return ResponseEntity.ok(new MemberResponse(member));
    } else {
        URI location = URI.create("/members/" + id);
        return ResponseEntity.created(location).body(new MemberResponse(member));
    }
}
```

```
[PUT의 흐름]
클라이언트: PUT /members/1 ← "이 URI에 넣어줘"
서버: /members/1 없음 → 생성 or 있음 → 교체

클라이언트: PUT /members/99 ← "이 URI에 넣어줘"
서버: /members/99 없음 → 생성 or 있음 → 교체

→ 클라이언트가 URI를 직접 지정
→ 서버는 해당 URI에 리소스를 생성하거나 교체
```

## 비유로 이해하기

```
[POST — 식당 번호표]
손님: "자리 하나 주세요" (번호를 지정하지 않음)
직원: "3번 테이블로 안내해드릴게요" (직원이 번호 결정)
→ 손님은 몇 번 테이블인지 미리 알 수 없음

[PUT — 예약석]
손님: "7번 테이블에 앉을게요" (번호를 직접 지정)
직원: "네, 7번 테이블 준비해드리겠습니다" (손님이 번호 결정)
→ 손님이 원하는 테이블을 직접 선택
```

## 실무에서의 차이

```
[POST가 적합한 경우 — 대부분의 생성 작업]
회원가입:    POST /members       → 서버가 회원번호 부여
주문:       POST /orders        → 서버가 주문번호 부여
게시글 작성: POST /posts         → 서버가 게시글 ID 부여

→ 클라이언트가 ID를 알 필요 없음
→ 서버가 DB auto_increment 등으로 자동 생성

[PUT이 적합한 경우 — 클라이언트가 식별자를 아는 경우]
파일 업로드:      PUT /files/report-2025.pdf   → 파일명을 클라이언트가 지정
설정 저장:        PUT /settings/notification   → 설정 키를 클라이언트가 알고 있음
외부 ID 연동:     PUT /users/github-12345      → 외부 시스템의 ID를 그대로 사용
```

## 요청 대상 URI의 의미 차이

|항목|POST|PUT|
|---|---|---|
|**요청 URI**|`/members` (컬렉션)|`/members/1` (개별 리소스)|
|**URI의 의미**|"이 컬렉션에 추가해줘"|"이 URI의 리소스를 이 데이터로 설정해줘"|
|**서버의 역할**|새 URI를 생성하여 부여|지정된 URI에 리소스를 배치|

```
POST /members     → "members 컬렉션에 새 멤버를 추가해줘"
                    서버: "알겠어, /members/1로 만들었어"

PUT /members/1    → "/members/1을 이 데이터로 설정해줘"
                    서버: "알겠어, /members/1을 설정했어"
```

## 면접 포인트

- POST는 **컬렉션 URI**에 요청하고 서버가 새 리소스의 URI를 결정하는 반면, PUT은 **개별 리소스 URI**에 요청하여 클라이언트가 URI를 직접 지정합니다.
- 실무에서 대부분의 생성 작업은 **POST를 사용**합니다. DB가 auto_increment로 ID를 생성하는 것이 일반적이고, 클라이언트가 ID를 직접 지정할 필요가 거의 없기 때문입니다.
- PUT이 멱등한 이유도 여기에 있습니다. 클라이언트가 **같은 URI에 같은 데이터를 반복 전송**하면 항상 같은 결과가 되지만, POST는 컬렉션에 요청하므로 **매번 새로운 URI가 생성**됩니다.