클라이언트와 서버가 HTTPS 통신을 시작하기 전에 **암호화 알고리즘 협상, 서버 인증, 세션 키 교환**을 수행하여 안전한 암호화 채널을 수립하는 과정입니다.

## 핵심 개념

|항목|내용|
|---|---|
|**정식 명칭**|Transport Layer Security Handshake|
|**목적**|암호화 통신을 위한 사전 협상|
|**위치**|TCP 3-Way Handshake 이후, 데이터 전송 이전|
|**결과**|양측이 동일한 세션 키(대칭 키)를 공유|
|**현재 표준**|TLS 1.3 (2018년)|

## HTTPS 연결 전체 흐름에서의 위치

```
클라이언트                              서버
    │                                   │
    │◄──── TCP 3-Way Handshake ────►    │  ① TCP 연결 수립
    │      SYN → SYN-ACK → ACK         │
    │                                   │
    │◄──── TLS Handshake ──────────►    │  ② 암호화 채널 수립
    │      (암호화 협상 + 키 교환)         │
    │                                   │
    │◄──── 암호화된 데이터 통신 ────────►  │  ③ 실제 데이터 전송
    │      (HTTP 요청/응답)              │
    │                                   │
```

## TLS 1.2 Handshake (4단계)

```
클라이언트                                    서버
    │                                         │
    │──── ① Client Hello ─────────────→       │
    │  - 지원하는 TLS 버전                      │
    │  - 지원하는 암호 스위트 목록                │
    │  - Client Random (난수)                  │
    │                                         │
    │←─── ② Server Hello ─────────────        │
    │  - 선택한 TLS 버전                        │
    │  - 선택한 암호 스위트                      │
    │  - Server Random (난수)                  │
    │                                         │
    │←─── ③ Certificate ──────────────        │
    │  - 서버의 SSL/TLS 인증서 (공개 키 포함)     │
    │                                         │
    │←─── ④ Server Hello Done ────────        │
    │                                         │
    │  [클라이언트: 인증서 검증]                   │
    │  - 인증 기관(CA) 서명 확인                  │
    │  - 유효 기간 확인                          │
    │  - 도메인 일치 확인                         │
    │                                         │
    │──── ⑤ Client Key Exchange ──────→       │
    │  - Pre-Master Secret                    │
    │    (서버 공개 키로 암호화하여 전송)           │
    │                                         │
    │  [양쪽: 세션 키 생성]                       │
    │  Client Random + Server Random           │
    │  + Pre-Master Secret → 세션 키 도출        │
    │                                         │
    │──── ⑥ Change Cipher Spec ───────→       │
    │  "이제부터 암호화 통신합니다"                 │
    │                                         │
    │──── ⑦ Finished (암호화) ────────→        │
    │                                         │
    │←─── ⑧ Change Cipher Spec ───────        │
    │←─── ⑨ Finished (암호화) ────────         │
    │                                         │
    │◄════ 암호화된 통신 시작 ════════►          │
```

## TLS 1.3 Handshake (간소화 — 1-RTT)

TLS 1.3은 왕복 횟수를 줄여 **1-RTT(1 Round Trip Time)**로 핸드셰이크를 완료합니다.

```
클라이언트                                    서버
    │                                         │
    │──── ① Client Hello ─────────────→       │
    │  - 지원하는 TLS 버전                      │
    │  - 지원하는 암호 스위트 목록                │
    │  - Client Random                        │
    │  - Key Share (DH 공개 값)  ← ★ 미리 전송  │
    │                                         │
    │←─── ② Server Hello ─────────────        │
    │  - 선택한 암호 스위트                      │
    │  - Server Random                        │
    │  - Key Share (DH 공개 값)                 │
    │                                         │
    │←─── ③ Certificate + Verify ─────        │
    │←─── ④ Finished ─────────────────        │
    │                                         │
    │  [양쪽: DH 공개 값으로 세션 키 즉시 도출]    │
    │                                         │
    │──── ⑤ Finished ─────────────────→       │
    │                                         │
    │◄════ 암호화된 통신 시작 ════════►          │
```

## TLS 1.2 vs TLS 1.3

|항목|TLS 1.2|TLS 1.3|
|---|---|---|
|**왕복 횟수**|2-RTT|1-RTT (재연결 시 0-RTT 가능)|
|**키 교환**|RSA 또는 DHE|DHE/ECDHE만 허용|
|**암호 스위트**|다양 (일부 취약)|안전한 것만 5개로 축소|
|**전방 비밀성**|선택 사항|필수 (Perfect Forward Secrecy)|
|**핸드셰이크 암호화**|일부만 암호화|인증서부터 암호화|
|**성능**|상대적으로 느림|빠름|

```
연결 수립 시간 비교:

TLS 1.2:
  TCP (1 RTT) + TLS (2 RTT) = 3 RTT

TLS 1.3:
  TCP (1 RTT) + TLS (1 RTT) = 2 RTT

TLS 1.3 재연결 (0-RTT):
  TCP (1 RTT) + TLS (0 RTT) = 1 RTT ← 이전 세션 정보 재사용
```

## 핸드셰이크에서 사용하는 암호화 방식

|단계|암호화 방식|목적|
|---|---|---|
|**키 교환**|비대칭 암호화 (RSA, ECDHE)|세션 키를 안전하게 교환|
|**서버 인증**|디지털 인증서 (CA 서명)|서버 신원 확인|
|**데이터 전송**|대칭 암호화 (AES-GCM 등)|실제 데이터 암호화 (빠름)|

```
왜 비대칭 + 대칭을 함께 사용하는가?

비대칭 암호화 (RSA, ECDHE):
  - 장점: 키 교환이 안전
  - 단점: 매우 느림 (데이터 전송에 부적합)

대칭 암호화 (AES):
  - 장점: 매우 빠름 (데이터 전송에 적합)
  - 단점: 키를 어떻게 안전하게 공유할 것인가?

→ 해결: 비대칭으로 대칭 키를 교환 → 이후 대칭 키로 통신

┌──────────────────────────────────────────┐
│  TLS Handshake (비대칭 암호화)              │
│  → 세션 키(대칭 키) 교환                    │
├──────────────────────────────────────────┤
│  데이터 전송 (대칭 암호화)                   │
│  → 세션 키로 빠르게 암호화/복호화             │
└──────────────────────────────────────────┘
```

## 인증서 검증 과정

```
서버 인증서 수신
    │
    ▼
① 인증서 체인 확인
   서버 인증서 → 중간 CA 인증서 → 루트 CA 인증서
                                      ↑
                               브라우저에 내장된
                               신뢰할 수 있는 루트 CA 목록

② CA 서명 검증
   CA의 공개 키로 인증서의 디지털 서명 확인
   → 위조되지 않았는지 확인

③ 유효 기간 확인
   현재 날짜가 인증서의 유효 기간 내인지 확인

④ 도메인 일치 확인
   인증서의 CN/SAN 필드가 접속한 도메인과 일치하는지 확인

⑤ 폐기 여부 확인
   CRL 또는 OCSP로 인증서가 폐기되었는지 확인

  모두 통과 → 핸드셰이크 계속
  하나라도 실패 → 경고 또는 연결 거부
```

## 전방 비밀성 (Perfect Forward Secrecy)

|항목|RSA 키 교환|DHE/ECDHE 키 교환|
|---|---|---|
|**전방 비밀성**|없음|있음|
|**서버 개인 키 유출 시**|과거 모든 통신 복호화 가능|과거 통신 복호화 불가|
|**세션 키 생성**|서버 개인 키에 의존|매 세션마다 임시 키 쌍 생성|
|**TLS 1.3**|사용 불가 (제거됨)|필수|

```
[RSA — 전방 비밀성 없음]
서버 개인 키 유출 → 과거에 캡처해둔 모든 트래픽 복호화 가능

[ECDHE — 전방 비밀성 있음]
세션 1: 임시 키 쌍 A 사용 → 세션 종료 → 키 폐기
세션 2: 임시 키 쌍 B 사용 → 세션 종료 → 키 폐기

서버 개인 키 유출되어도:
  → 임시 키는 이미 폐기됨
  → 과거 트래픽 복호화 불가
```

## Java에서의 TLS 핸드셰이크

```java
// HTTPS 연결 시 내부적으로 TLS 핸드셰이크 수행
HttpsURLConnection conn = (HttpsURLConnection)
    new URL("https://example.com").openConnection();
conn.connect();  // TCP 연결 + TLS 핸드셰이크 수행

// 연결 후 TLS 정보 확인
System.out.println("암호 스위트: " + conn.getCipherSuite());
// ex) TLS_AES_256_GCM_SHA384

Certificate[] certs = conn.getServerCertificates();
X509Certificate cert = (X509Certificate) certs[0];
System.out.println("발급자: " + cert.getIssuerDN());
System.out.println("만료일: " + cert.getNotAfter());

// Spring WebClient에서 TLS 설정
SslContext sslContext = SslContextBuilder.forClient()
    .trustManager(InsecureTrustManagerFactory.INSTANCE) // 개발용 (운영 금지)
    .protocols("TLSv1.3")  // TLS 1.3 강제
    .build();
```