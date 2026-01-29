사용자 인증 정보를 담은 암호화된 토큰입니다. 서버에 상태를 저장하지 않고 토큰 자체에 정보를 담아 인증을 처리합니다.

## 왜 필요한가?

- 세션은 서버에 저장 → 서버 확장 시 세션 공유 문제
- JWT는 토큰에 정보가 담김 → 서버가 상태를 저장할 필요 없음
- 마이크로서비스, 모바일 앱 환경에 적합

## JWT 구조

```
xxxxx.yyyyy.zzzzz
  │      │     │
Header.Payload.Signature
```

|부분|내용|
|---|---|
|**Header**|토큰 타입, 암호화 알고리즘|
|**Payload**|사용자 정보, 만료 시간 등 (클레임)|
|**Signature**|위변조 방지용 서명|

## 실제 예시

```
// Header
{ "alg": "HS256", "typ": "JWT" }

// Payload
{ "userId": 123, "name": "홍길동", "exp": 1699999999 }

// Signature
HMACSHA256(base64(header) + "." + base64(payload), 비밀키)
```

## 동작 방식

```
1. 로그인
   클라이언트 ──── ID/PW ────▶ 서버
   
2. 토큰 발급
   클라이언트 ◀──── JWT ───── 서버

3. 이후 요청
   클라이언트 ──── Authorization: Bearer <JWT> ────▶ 서버
   서버: 서명 검증 → 유효하면 통과
```

## 세션 vs JWT

|항목|세션|JWT|
|---|---|---|
|저장 위치|서버|클라이언트|
|상태|Stateful|Stateless|
|확장성|세션 공유 필요|서버 확장 쉬움|
|무효화|즉시 가능|어려움 (만료까지 유효)|
|용량|세션 ID만 전송|토큰 전체 전송|

## JWT 저장 위치

|위치|장점|단점|
|---|---|---|
|**localStorage**|사용 편리|XSS 취약|
|**Cookie (HttpOnly)**|XSS 방어|CSRF 주의|
|**메모리**|가장 안전|새로고침 시 소멸|

## JWT 단점과 해결

|문제|해결|
|---|---|
|토큰 탈취|짧은 만료 시간 + Refresh Token|
|즉시 무효화 불가|블랙리스트 관리 (Redis)|
|토큰 크기 큼|필요한 정보만 담기|

## Refresh Token 패턴

```
Access Token: 짧은 수명 (15분~1시간)
Refresh Token: 긴 수명 (7일~30일)

Access Token 만료 → Refresh Token으로 재발급
```
