Simple Request(단순 요청)는 **Preflight 없이 브라우저가 서버에 바로 요청을 보내는 CORS 요청**으로, 특정 조건을 모두 충족해야 합니다.

## 단순 요청의 조건

세 가지 조건을 **모두** 만족해야 단순 요청으로 분류됩니다.

```
[조건 1] 메서드: GET, HEAD, POST 중 하나
[조건 2] 헤더: 기본 허용 헤더만 사용
[조건 3] Content-Type: 허용된 3가지 중 하나 (POST인 경우)

→ 하나라도 불충족 시 Preflight 발생
```

### 조건 1 — 허용 메서드

|메서드|단순 요청|Preflight|
|---|---|---|
|**GET**|✅||
|**HEAD**|✅||
|**POST**|✅ (Content-Type 조건 추가)||
|PUT||✅ Preflight 발생|
|DELETE||✅ Preflight 발생|
|PATCH||✅ Preflight 발생|

### 조건 2 — 허용 헤더

```
[수동 설정 가능한 헤더 — 이것만 허용]
Accept
Accept-Language
Content-Language
Content-Type (조건 3 참고)

[이외의 헤더 사용 시 → Preflight 발생]
Authorization          ← JWT 인증 시 사용 → Preflight
X-Custom-Header        ← 커스텀 헤더 → Preflight
X-Requested-With       ← Ajax 식별 헤더 → Preflight
Cache-Control          ← 캐시 제어 → Preflight
```

### 조건 3 — 허용 Content-Type

```
[POST 요청 시 이 3가지만 허용]

application/x-www-form-urlencoded   ← HTML 폼 기본값
multipart/form-data                 ← 파일 업로드
text/plain                          ← 평문 텍스트

[이외의 Content-Type → Preflight 발생]
application/json                    ← REST API 표준 → Preflight
application/xml                     ← XML 전송 → Preflight
text/html                           ← HTML 전송 → Preflight
```

## 단순 요청 vs Preflight 예시

### 단순 요청 ✅

```javascript
// ✅ GET + 기본 헤더만
fetch('https://api.example.com/products', {
    method: 'GET'
});

// ✅ POST + form-urlencoded
fetch('https://api.example.com/login', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: 'username=hong&password=1234'
});

// ✅ POST + text/plain
fetch('https://api.example.com/log', {
    method: 'POST',
    headers: {
        'Content-Type': 'text/plain'
    },
    body: '로그 메시지입니다'
});

// ✅ HEAD + 기본 헤더만
fetch('https://api.example.com/health', {
    method: 'HEAD'
});
```

### Preflight 발생 ❌

```javascript
// ❌ Content-Type: application/json
fetch('https://api.example.com/products', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'    // ← 조건 3 불충족
    },
    body: JSON.stringify({ name: '이어폰' })
});

// ❌ Authorization 헤더
fetch('https://api.example.com/products', {
    method: 'GET',
    headers: {
        'Authorization': 'Bearer eyJhbG...'   // ← 조건 2 불충족
    }
});

// ❌ DELETE 메서드
fetch('https://api.example.com/products/1', {
    method: 'DELETE'                           // ← 조건 1 불충족
});

// ❌ 커스텀 헤더
fetch('https://api.example.com/products', {
    method: 'GET',
    headers: {
        'X-Custom-Header': 'value'            // ← 조건 2 불충족
    }
});

// ❌ PUT 메서드 + application/json
fetch('https://api.example.com/products/1', {
    method: 'PUT',                            // ← 조건 1 불충족
    headers: {
        'Content-Type': 'application/json'    // ← 조건 3도 불충족
    },
    body: JSON.stringify({ name: '키보드' })
});
```

## 왜 이 조건인가 — 역사적 이유

```
[CORS 등장 이전 (2009년 이전)]

브라우저가 이미 보낼 수 있었던 요청들:

HTML 폼:
<form action="https://other.com/login" method="POST">
→ Content-Type: application/x-www-form-urlencoded
→ 이미 Cross-Origin 전송 가능했음

이미지 태그:
<img src="https://other.com/image.png">
→ GET 요청
→ 이미 Cross-Origin 전송 가능했음

스크립트 태그:
<script src="https://other.com/script.js"></script>
→ GET 요청
→ 이미 Cross-Origin 전송 가능했음

→ 이미 가능했던 요청들을 굳이 Preflight로 막을 필요 없음
→ 이것들이 단순 요청 조건의 기준이 됨
```

```
[CORS 이후에 새로 가능해진 것들]

JavaScript의 fetch/XMLHttpRequest로:
→ PUT, DELETE 메서드 전송
→ Content-Type: application/json
→ Authorization 헤더 설정
→ 커스텀 헤더 추가

→ 이전에 불가능했던 새로운 형태의 요청
→ 서버가 예상하지 못할 수 있음
→ Preflight로 서버에 사전 확인 필요
```

```
[정리]

단순 요청 = CORS 이전에도 가능했던 요청
           → 서버가 이미 대응할 수 있으므로 Preflight 불필요

비단순 요청 = CORS 이후에 새로 가능해진 요청
            → 서버가 예상하지 못할 수 있으므로 Preflight 필요
```

## 단순 요청의 통신 흐름

```
[단순 요청 — 1번 통신]

브라우저                                  서버
   │                                      │
   │  GET /api/products                   │
   │  Origin: https://frontend.com        │
   │ ─────────────────────────────────→    │
   │                                      │
   │  200 OK                              │
   │  Access-Control-Allow-Origin:        │
   │    https://frontend.com              │
   │  {"products": [...]}                 │
   │ ←─────────────────────────────────   │

→ OPTIONS 없이 바로 본 요청 전송
→ 서버 응답의 CORS 헤더를 확인
→ 허용되면 응답을 JavaScript에 전달
→ 거부되면 응답을 차단 (서버는 이미 처리함 ⚠️)


[비단순 요청 — 2번 통신]

브라우저                                  서버
   │                                      │
   │  ① OPTIONS /api/products             │  ← Preflight
   │ ─────────────────────────────────→    │
   │  ② 200 OK (CORS 헤더)               │
   │ ←─────────────────────────────────   │
   │                                      │
   │  ③ POST /api/products               │  ← 본 요청
   │ ─────────────────────────────────→    │
   │  ④ 201 Created                      │
   │ ←─────────────────────────────────   │
```

## 단순 요청이어도 CORS 검증은 발생한다

```
[중요: 단순 요청 ≠ CORS 검증 없음]

단순 요청:
1. 브라우저: 서버에 바로 요청 전송
2. 서버: 요청을 정상 처리하고 응답
3. 브라우저: 응답의 CORS 헤더 확인
   - Access-Control-Allow-Origin이 일치하면 → JS에 응답 전달 ✅
   - 일치하지 않으면 → JS에 응답 차단 ❌

→ 서버는 이미 요청을 처리함!
→ Preflight와 달리 "사전 차단"이 아닌 "사후 차단"
→ 이것이 단순 요청의 한계
```

```
[단순 요청의 위험성]

evil.com에서:
<form action="https://bank.com/transfer" method="POST">
    <input name="to" value="hacker" />
    <input name="amount" value="1000000" />
</form>

→ POST + form-urlencoded = 단순 요청 조건 충족
→ Preflight 없이 바로 bank.com에 전송
→ 서버가 처리한 후 브라우저가 응답만 차단
→ 하지만 서버에서는 이미 처리됨 ❌

→ 이것이 CSRF 공격
→ 단순 요청은 Preflight로 보호할 수 없으므로
→ CSRF Token, SameSite 쿠키 등 별도 방어 필요
```

## 실무에서 단순 요청이 거의 없는 이유

```
현대 REST API의 일반적인 구성:

1. Content-Type: application/json → Preflight ✅
2. Authorization: Bearer JWT     → Preflight ✅
3. PUT, DELETE 메서드 사용        → Preflight ✅
4. 커스텀 헤더 (X-Request-Id 등) → Preflight ✅

→ 4가지 중 하나라도 해당하면 Preflight 발생
→ 실무 API는 거의 모두 해당
→ 단순 요청은 정적 리소스 조회, 단순 GET 등에서만 해당
```

|실무 상황|단순 요청 여부|이유|
|---|---|---|
|GET /api/products (인증 없음)|✅|기본 헤더만 사용|
|GET /api/products (JWT)|❌|Authorization 헤더|
|POST /api/products (JSON)|❌|application/json|
|PUT /api/products/1|❌|PUT 메서드|
|DELETE /api/products/1|❌|DELETE 메서드|
|POST /login (폼 전송)|✅|form-urlencoded|
|이미지, CSS, JS 로드|✅|단순 GET|

## 면접 포인트

- 단순 요청의 조건은 **CORS 이전에 브라우저가 이미 보낼 수 있었던 요청**을 기준으로 정해졌습니다. HTML 폼, 이미지 태그 등으로 이미 가능했던 요청은 서버가 대응할 수 있으므로 Preflight가 불필요하고, 그 이후 새로 가능해진 요청만 Preflight로 사전 검증합니다.
- 단순 요청이라도 **CORS 검증은 응답 시점에 발생**하며, 서버는 요청을 이미 처리한 상태에서 브라우저가 응답만 차단합니다. 이것이 Preflight와의 핵심 차이이며, **단순 요청으로 가능한 공격(CSRF)은 CORS가 아닌 CSRF Token 등 별도 메커니즘으로 방어**해야 합니다.
- 실무에서는 `application/json`, `Authorization` 헤더, PUT/DELETE 메서드 등을 사용하므로 **대부분의 API 요청은 비단순 요청**이며, `Max-Age`로 Preflight 결과를 캐싱하여 성능 영향을 최소화합니다.
- 