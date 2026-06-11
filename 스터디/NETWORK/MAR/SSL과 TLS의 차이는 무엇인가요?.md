---
title: "SSL과 TLS의 차이는 무엇인가요?"
tags: [HTTPS, 보안]
status: published
---

[[SSL]]의 취약점을 개선하여 만든 것이 [[TLS]]로, 현재 SSL은 deprecated되었고 실질적으로 TLS가 표준으로 사용되고 있습니다.

## 역사적 흐름

```
SSL 1.0 (미공개)
→ SSL 2.0 (1995, 취약점 발견)
→ SSL 3.0 (1996, 취약점 발견 - POODLE 공격)
→ TLS 1.0 (1999, SSL 3.0 기반으로 개선)
→ TLS 1.1 (2006)
→ TLS 1.2 (2008, 현재도 널리 사용)
→ TLS 1.3 (2018, 현재 최신 표준) O
```

> SSL 2.0, 3.0 / TLS 1.0, 1.1은 현재 **모두 deprecated**

## SSL vs TLS 비교

|항목|SSL|TLS|
|---|---|---|
|**현재 상태**|deprecated|표준 사용 중|
|**보안성**|취약점 다수 발견|지속적으로 개선|
|**Handshake**|느림|빠름 (특히 TLS 1.3)|
|**암호화 알고리즘**|구형 (RC4, DES 등)|최신 (AES, ChaCha20 등)|
|**인증**|단방향 위주|양방향 인증 지원|

## TLS 1.2 vs TLS 1.3

|항목|TLS 1.2|TLS 1.3|
|---|---|---|
|**Handshake 왕복**|2-RTT|1-RTT|
|**취약 암호화 제거**|일부 허용|완전 제거|
|**0-RTT**|X|O (재연결 시)|
|**성능**|보통|빠름|

## Handshake 비교

```
[TLS 1.2] - 2 RTT
클라이언트 → 서버: ClientHello
클라이언트 ← 서버: ServerHello + 인증서
클라이언트 → 서버: 키 교환
클라이언트 ← 서버: 완료
→ 통신 시작

[TLS 1.3] - 1 RTT
클라이언트 → 서버: ClientHello + 키 교환 정보
클라이언트 ← 서버: ServerHello + 인증서 + 완료
→ 통신 시작 (왕복 1회 줄어듦)
```

## 그럼 HTTPS의 SSL은?

```
HTTPS = HTTP + SSL/TLS
실제로는 TLS를 사용하지만
"SSL"이라는 명칭이 관습적으로 혼용되어 사용됨
ex) "SSL 인증서" = 사실상 TLS 인증서
```

> 현재 **SSL은 사용하면 안 되며**, 최소 TLS 1.2 이상, 가능하면 **TLS 1.3 사용을 권장**합니다.