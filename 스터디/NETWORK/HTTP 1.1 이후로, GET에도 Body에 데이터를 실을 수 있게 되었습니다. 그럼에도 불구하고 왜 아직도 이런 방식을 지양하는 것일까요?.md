HTTP 1.1 스펙상 GET 요청에 Body를 포함하는 것이 금지되지는 않지만, **대부분의 인프라와 라이브러리가 GET Body를 무시하거나 제거하기 때문에 사실상 신뢰할 수 없는 방식**입니다.

## [[HTTP]] 스펙에서의 GET Body

```
[RFC 7231 (HTTP/1.1)]
"A payload within a GET request message has no defined semantics"

→ GET 요청에 Body를 보내는 것 자체는 금지하지 않음
→ 하지만 Body에 "정의된 의미가 없다"고 명시
→ 서버가 Body를 어떻게 처리할지 보장하지 않음

[RFC 9110 (2022, 최신)]
"Although request message framing is independent of the method used,
 content received in a GET request has no generally defined semantics"

→ 여전히 GET Body에 대한 의미를 정의하지 않음
```

## 지양하는 이유

### 1. 중간 인프라가 GET Body를 제거하거나 무시

```
클라이언트 → 프록시 → CDN → 로드밸런서 → 서버

GET /search HTTP/1.1
Content-Type: application/json

{"query": "홍길동", "filters": {"age": 25}}

프록시: GET에 Body? → Body 제거 후 전달 ❌
CDN: GET 요청 캐싱 → Body 무시하고 URL만으로 캐시 키 생성 ❌
로드밸런서: Body 없는 GET으로 전달 ❌

→ 서버에 도달할 때 Body가 사라져 있을 수 있음
```

|인프라|GET Body 처리|
|---|---|
|**Nginx**|기본적으로 전달하지만 proxy 설정에 따라 제거될 수 있음|
|**AWS ALB/CloudFront**|GET Body를 제거할 수 있음|
|**CDN (Cloudflare 등)**|캐시 키에 Body를 포함하지 않음 → 무시|
|**일부 프록시/방화벽**|GET Body를 비정상 요청으로 판단하여 차단|

### 2. 클라이언트 라이브러리가 지원하지 않거나 제한

```javascript
// JavaScript fetch — GET Body 지원 안 함
fetch("/search", {
    method: "GET",
    body: JSON.stringify({query: "홍길동"})  // 일부 브라우저에서 에러 ❌
});

// XMLHttpRequest — 스펙상 GET Body 전송 가능하나 브라우저마다 다름
```

```java
// Java HttpURLConnection — GET Body 지원하지 않음
HttpURLConnection conn = (HttpURLConnection) url.openConnection();
conn.setRequestMethod("GET");
conn.setDoOutput(true);  // GET에서는 예외 발생할 수 있음 ❌

// RestTemplate — GET Body 기본 미지원
restTemplate.exchange(
    url, HttpMethod.GET,
    new HttpEntity<>(body, headers),  // Body가 무시될 수 있음 ⚠️
    String.class
);
```

```
[다양한 클라이언트의 GET Body 지원 현황]
브라우저 fetch API:  ❌ 미지원 (에러 또는 무시)
axios:              ❌ GET 요청 시 data 무시
OkHttp:             ❌ GET에 Body 설정 시 예외
curl:               ✅ -d 옵션으로 가능 (비표준 사용)
Postman:            ✅ 가능하지만 경고 표시
```

### 3. [[캐싱]]이 불가능

```
[GET의 가장 큰 장점 — 캐싱]
GET /members?name=홍길동&age=25
→ URL이 캐시 키 → 같은 URL이면 캐시된 응답 반환

[GET Body 사용 시 — 캐싱 불가]
GET /members
Body: {"name": "홍길동", "age": 25}

→ 브라우저, CDN, 프록시 모두 URL만으로 캐시 키 생성
→ Body가 다르더라도 URL이 같으면 같은 캐시 반환
→ 잘못된 결과 반환 ❌
```

```
GET /search (Body: {"query": "사과"}) → 결과A 캐싱
GET /search (Body: {"query": "바나나"}) → URL 동일 → 결과A 반환 ❌

→ Body를 무시하고 URL만으로 캐싱하므로
→ 다른 검색어임에도 같은 결과를 반환하는 문제 발생
```

### 4. 브라우저 히스토리, 북마크, 링크 공유 불가

```
[쿼리스트링 사용 시]
GET /search?query=홍길동&age=25
→ URL 복사하여 공유 가능 ✅
→ 브라우저 북마크 가능 ✅
→ 뒤로가기 시 동일 결과 ✅

[GET Body 사용 시]
GET /search (Body: {"query": "홍길동", "age": 25})
→ URL만으로는 검색 조건을 알 수 없음
→ 링크 공유 불가 ❌
→ 북마크 불가 ❌
→ 뒤로가기 시 Body가 없어 동일 결과 보장 불가 ❌
```

## 그럼 복잡한 검색 조건은 어떻게 전달하나

### 방법 1: 쿼리스트링으로 전달 (기본)

```http
GET /members?name=홍길동&age=25&sort=name,asc&page=0&size=20 HTTP/1.1
```

```java
@GetMapping("/members")
public ResponseEntity<Page<MemberResponse>> search(
        @RequestParam String name,
        @RequestParam int age,
        @PageableDefault(sort = "name") Pageable pageable) {
    return ResponseEntity.ok(memberService.search(name, age, pageable));
}
```

### 방법 2: POST를 사용 (검색 조건이 매우 복잡한 경우)

```http
POST /members/search HTTP/1.1
Content-Type: application/json

{
    "name": "홍길동",
    "ageRange": {"min": 20, "max": 30},
    "addresses": ["서울", "경기"],
    "skills": ["Java", "Spring"],
    "joinDateRange": {"from": "2024-01-01", "to": "2025-12-31"}
}
```

```java
@PostMapping("/members/search")
public ResponseEntity<Page<MemberResponse>> complexSearch(
        @RequestBody ComplexSearchRequest request,
        @PageableDefault Pageable pageable) {
    return ResponseEntity.ok(memberService.complexSearch(request, pageable));
}
```

### 방법 3: Elasticsearch 스타일

```http
// Elasticsearch는 GET Body를 허용하는 대표적인 사례
// 자체 HTTP 클라이언트를 사용하여 인프라 제약을 우회

GET /index/_search
{
    "query": {
        "bool": {
            "must": [{"match": {"name": "홍길동"}}]
        }
    }
}

// 하지만 Elasticsearch도 POST를 대안으로 허용
POST /index/_search  ← 동일 동작
```

## 판단 기준

|상황|권장 방식|
|---|---|
|단순 조회 (파라미터 소수)|GET + 쿼리스트링|
|복잡한 검색 (중첩 객체, 배열 등)|POST + Body|
|URL 길이 제한 초과 (약 2,048자)|POST + Body|
|검색 조건에 민감 정보 포함|POST + Body|
|캐싱/북마크/공유가 필요|GET + 쿼리스트링|

## 면접 포인트

- GET Body는 스펙상 금지되지 않지만, **"정의된 의미가 없다"고 명시**되어 있어 서버와 중간 인프라가 이를 어떻게 처리할지 보장되지 않습니다.
- 실무적으로 프록시, CDN, 로드밸런서, 브라우저, HTTP 클라이언트 라이브러리 등 **요청이 거치는 거의 모든 계층에서 GET Body를 무시하거나 제거할 수 있어** 신뢰할 수 없습니다.
- GET의 핵심 이점인 **캐싱, 북마크, 링크 공유**가 모두 URL 기반으로 동작하므로, Body에 데이터를 넣으면 이러한 이점을 잃게 됩니다.
- 복잡한 검색 조건이 필요한 경우에는 **POST /리소스/search 패턴**을 사용하는 것이 실무적인 해결 방법입니다.