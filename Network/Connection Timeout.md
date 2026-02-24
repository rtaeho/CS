클라이언트가 서버에 TCP 연결을 시도할 때 **지정된 시간 내에 연결이 수립되지 않으면** 연결 시도를 포기하고 오류를 발생시키는 메커니즘입니다.

## Connection Timeout vs Read Timeout

| 항목         | Connection Timeout             | Read Timeout             |
| ---------- | ------------------------------ | ------------------------ |
| **발생 시점**  | TCP 연결 수립 단계 (3-Way Handshake) | 연결 수립 후 데이터 수신 단계        |
| **의미**     | 서버와 연결 자체가 안 됨                 | 연결은 됐지만 응답이 안 옴          |
| **원인**     | 서버 다운, 네트워크 차단, 방화벽            | 서버 과부하, 느린 처리, 대용량 응답    |
| **TCP 상태** | SYN 전송 후 SYN-ACK 미수신           | ESTABLISHED 상태에서 데이터 미수신 |

```
[Connection Timeout]
클라이언트                     서버
    │                          │
    │──── SYN ────→            │ (서버 다운/방화벽 차단)
    │                          │
    │  ... 응답 없음 ...        │
    │                          │
    │──── SYN 재전송 ──→        │
    │                          │
    │  ... 응답 없음 ...        │
    │                          │
    ✕ Connection Timeout 발생   │

[Read Timeout]
클라이언트                     서버
    │──── SYN ────→            │
    │←── SYN-ACK ──            │
    │──── ACK ────→            │  ← 연결 수립 완료
    │                          │
    │──── HTTP 요청 ──→        │
    │                          │  (서버가 처리 중...)
    │  ... 응답 없음 ...        │
    │                          │
    ✕ Read Timeout 발생         │
```

## Connection Timeout이 발생하는 원인

|원인|설명|
|---|---|
|**서버 다운**|서버가 꺼져 있거나 프로세스가 죽어 있음|
|**방화벽 차단**|방화벽이 SYN 패킷을 드롭 (RST도 안 보냄)|
|**네트워크 장애**|라우팅 문제, 케이블 단절 등|
|**잘못된 IP/포트**|존재하지 않는 주소에 연결 시도|
|**서버 백로그 초과**|SYN 큐가 가득 차서 새 연결을 수용 못함|
|**DNS 지연**|도메인 → IP 변환이 오래 걸림 (넓은 의미)|

## 방화벽 차단 vs 서버 포트 닫힘

```
[방화벽이 패킷을 드롭하는 경우 — Timeout 발생]
클라이언트 ── SYN ──→ 방화벽(DROP) ──✕ 서버
             응답 없음 → 재전송 → 재전송 → Timeout

[서버 포트가 닫혀 있는 경우 — 즉시 실패]
클라이언트 ── SYN ──→ 서버 (포트 닫힘)
클라이언트 ←── RST ─── 서버
             → Connection Refused (즉시 에러, Timeout 아님)
```

|상황|서버 응답|결과|
|---|---|---|
|방화벽 DROP|없음 (무응답)|Connection Timeout|
|방화벽 REJECT|RST 반환|Connection Refused (즉시)|
|포트 닫힘|RST 반환|Connection Refused (즉시)|
|서버 다운|없음 (무응답)|Connection Timeout|
|정상 연결|SYN-ACK 반환|연결 성공|

## TCP 재전송과 Timeout의 관계

Connection Timeout 전에 OS가 SYN 패킷을 자동으로 재전송합니다.

```
시간 ──→

0초    SYN 전송 (1차)
1초    응답 없음 → SYN 재전송 (2차)
3초    응답 없음 → SYN 재전송 (3차)     ← 지수적 백오프
7초    응답 없음 → SYN 재전송 (4차)        (1, 2, 4, 8, 16...)
15초   응답 없음 → SYN 재전송 (5차)
31초   응답 없음 → SYN 재전송 (6차)
~63초  OS 기본 Timeout → 연결 실패

※ Linux 기본: net.ipv4.tcp_syn_retries = 6 (약 127초)
※ 애플리케이션 Timeout이 OS보다 짧으면 먼저 포기
```

## Java에서의 Connection Timeout 설정

```java
// 1. URLConnection
URL url = new URL("https://example.com/api");
HttpURLConnection conn = (HttpURLConnection) url.openConnection();
conn.setConnectTimeout(3000);  // Connection Timeout: 3초
conn.setReadTimeout(5000);     // Read Timeout: 5초

// 2. Socket
Socket socket = new Socket();
socket.connect(
    new InetSocketAddress("example.com", 80),
    3000  // Connection Timeout: 3초
);
socket.setSoTimeout(5000);  // Read Timeout: 5초

// 3. Spring RestTemplate
SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
factory.setConnectTimeout(3000);  // Connection Timeout: 3초
factory.setReadTimeout(5000);     // Read Timeout: 5초
RestTemplate restTemplate = new RestTemplate(factory);

// 4. Spring WebClient (Reactor Netty)
HttpClient httpClient = HttpClient.create()
    .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 3000);

WebClient webClient = WebClient.builder()
    .clientConnector(new ReactorClientHttpConnector(httpClient))
    .build();
```

```java
// Connection Timeout 발생 시 예외
try {
    Socket socket = new Socket();
    socket.connect(new InetSocketAddress("10.0.0.1", 80), 3000);
} catch (SocketTimeoutException e) {
    // "Connect timed out" → Connection Timeout
    System.out.println("서버에 연결할 수 없습니다: " + e.getMessage());
} catch (ConnectException e) {
    // "Connection refused" → 포트 닫힘 (Timeout이 아님)
    System.out.println("연결 거부: " + e.getMessage());
}
```

## Timeout 값 설정 가이드

|환경|Connection Timeout 권장|Read Timeout 권장|
|---|---|---|
|**내부 서비스 (같은 DC)**|1~3초|3~5초|
|**외부 API 호출**|3~5초|5~30초|
|**데이터베이스**|2~5초|쿼리에 따라 다름|
|**CDN / 정적 리소스**|1~2초|3~5초|

```
⚠ Timeout을 설정하지 않으면?

클라이언트 → 서버 연결 시도 (서버 다운)
    │
    ▼
OS 기본 Timeout까지 대기 (Linux: ~127초, Windows: ~21초)
    │
    ▼
스레드가 2분 넘게 블로킹
    │
    ▼
다른 요청도 같은 상황 → 스레드 고갈 → 서비스 전체 장애

→ 반드시 적절한 Timeout 설정 필요!
```

## 전체 타임아웃 체계

```
클라이언트                                              서버
    │                                                  │
    │◄──── DNS Timeout ────►│                          │
    │      (도메인 → IP 변환) │                          │
    │                        │                          │
    │◄── Connection Timeout ──►│                        │
    │    (SYN → SYN-ACK 대기)  │                        │
    │                          │                        │
    │         연결 수립 완료      │                        │
    │                          │                        │
    │◄──────── Read Timeout ────────►│                  │
    │          (요청 후 응답 대기)      │                  │
    │                                │                  │
    │◄──────────── Write Timeout ────────────►│         │
    │              (데이터 전송 완료 대기)        │         │
    │                                        │         │
    │◄─────────────── Idle Timeout ────────────────────►│
    │                 (연결 유지 시간 초과)                 │
```