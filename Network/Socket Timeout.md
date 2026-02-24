소켓을 통한 네트워크 통신에서 **특정 작업이 지정된 시간 내에 완료되지 않으면 예외를 발생시키는 메커니즘의 총칭**으로, Connection Timeout과 Read Timeout을 포함합니다.

## Socket Timeout의 종류

|종류|발생 시점|의미|Java 설정|
|---|---|---|---|
|**Connection Timeout**|TCP 3-Way Handshake 단계|서버와 연결 자체가 안 됨|`socket.connect(addr, timeout)`|
|**Read Timeout (SO_TIMEOUT)**|연결 수립 후 데이터 수신 단계|연결은 됐지만 응답이 안 옴|`socket.setSoTimeout(timeout)`|
|**Write Timeout**|데이터 송신 단계|송신 버퍼가 가득 차서 전송 불가|일반적으로 OS 레벨에서 관리|

## 타임라인으로 보는 발생 시점

```
클라이언트                                    서버
    │                                         │
    │◄─── Connection Timeout ───►│            │
    │     SYN → SYN-ACK 대기      │            │
    │                             │            │
    │──── SYN ─────────────────→  │            │
    │←─── SYN-ACK ────────────── │            │
    │──── ACK ─────────────────→  │            │
    │         연결 수립 완료         │            │
    │                             │            │
    │◄────── Read Timeout ────────────────►│   │
    │        요청 후 응답 대기                │   │
    │                                      │   │
    │──── HTTP 요청 ──────────────────────→ │   │
    │                                      │   │
    │  ... 서버 처리 중, 응답 없음 ...        │   │
    │                                      │   │
    ✕  SocketTimeoutException: Read timed out  │
```

## Java에서의 Socket Timeout 설정

### 1. 순수 Socket

```java
// Connection Timeout + Read Timeout 설정
Socket socket = new Socket();

// Connection Timeout: 3초
socket.connect(new InetSocketAddress("example.com", 80), 3000);

// Read Timeout (SO_TIMEOUT): 5초
socket.setSoTimeout(5000);

try {
    InputStream in = socket.getInputStream();
    int data = in.read();  // 5초 내에 데이터가 안 오면 예외
} catch (SocketTimeoutException e) {
    System.out.println("Read timed out: " + e.getMessage());
}
```

### 2. HttpURLConnection

```java
URL url = new URL("https://example.com/api");
HttpURLConnection conn = (HttpURLConnection) url.openConnection();

conn.setConnectTimeout(3000);  // Connection Timeout: 3초
conn.setReadTimeout(5000);     // Read Timeout: 5초

try {
    int responseCode = conn.getResponseCode();
} catch (SocketTimeoutException e) {
    // Connection Timeout → "Connect timed out"
    // Read Timeout → "Read timed out"
    System.out.println(e.getMessage());
}
```

### 3. Spring RestTemplate

```java
SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
factory.setConnectTimeout(3000);
factory.setReadTimeout(5000);

RestTemplate restTemplate = new RestTemplate(factory);

try {
    String result = restTemplate.getForObject("https://example.com/api", String.class);
} catch (ResourceAccessException e) {
    // 내부에 SocketTimeoutException 포함
    System.out.println("요청 실패: " + e.getMessage());
}
```

### 4. Spring WebClient

```java
import reactor.netty.http.client.HttpClient;
import io.netty.channel.ChannelOption;

HttpClient httpClient = HttpClient.create()
    .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 3000)  // Connection Timeout
    .responseTimeout(Duration.ofSeconds(5));               // Read Timeout

WebClient webClient = WebClient.builder()
    .clientConnector(new ReactorClientHttpConnector(httpClient))
    .build();
```

## Connection Timeout vs Read Timeout 구분

```java
try {
    Socket socket = new Socket();
    socket.connect(new InetSocketAddress("10.0.0.1", 80), 3000);
    socket.setSoTimeout(5000);

    // ...데이터 송수신...

} catch (SocketTimeoutException e) {
    String msg = e.getMessage();
    if (msg.contains("Connect timed out")) {
        // Connection Timeout — 서버 연결 실패
        System.out.println("서버에 연결할 수 없습니다");
    } else if (msg.contains("Read timed out")) {
        // Read Timeout — 응답 없음
        System.out.println("서버가 응답하지 않습니다");
    }

} catch (ConnectException e) {
    // Connection Refused — 포트 닫힘 (Timeout이 아님, 즉시 실패)
    System.out.println("연결 거부됨");
}
```

## 발생 원인 비교

|구분|Connection Timeout|Read Timeout|
|---|---|---|
|서버 다운|✅|-|
|방화벽 DROP|✅|-|
|잘못된 IP/포트|✅|-|
|서버 과부하|△ (백로그 초과 시)|✅|
|느린 쿼리 / 처리|-|✅|
|대용량 응답|-|✅|
|네트워크 지연|✅|✅|

## Timeout을 설정하지 않으면?

```
기본 Timeout (OS 레벨):
  - Linux: tcp_syn_retries=6 → Connection Timeout ~127초
  - Read Timeout: 기본적으로 무제한 (영원히 블로킹)

[문제 상황]
요청 1 → 서버 응답 없음 → 스레드 블로킹 (무한 대기)
요청 2 → 서버 응답 없음 → 스레드 블로킹
요청 3 → 서버 응답 없음 → 스레드 블로킹
  ...
요청 N → 스레드 풀 고갈 → 서비스 전체 장애

┌────────────────────────────────────┐
│          스레드 풀 (200개)           │
├────────────────────────────────────┤
│ 스레드 1: 블로킹 (응답 대기)         │
│ 스레드 2: 블로킹 (응답 대기)         │
│ ...                                │
│ 스레드 200: 블로킹 (응답 대기)       │
├────────────────────────────────────┤
│ 새 요청 → 스레드 없음 → 요청 거부!   │
└────────────────────────────────────┘
```

## Timeout 설정 가이드

|환경|Connection Timeout|Read Timeout|
|---|---|---|
|**내부 서비스 (같은 DC)**|1~3초|3~5초|
|**외부 API**|3~5초|5~30초|
|**데이터베이스**|2~5초|쿼리에 따라 다름|
|**CDN / 정적 리소스**|1~2초|3~5초|
|**배치 / 대용량 처리**|3~5초|30~120초|

## 전체 Timeout 체계

```
클라이언트                                               서버
    │                                                    │
    │◄── DNS Timeout ──►│                                │
    │                    │                                │
    │◄── Connection Timeout ──►│                          │
    │   (socket.connect)        │                          │
    │                           │                          │
    │◄──────── Read Timeout (SO_TIMEOUT) ────────►│       │
    │          (socket.setSoTimeout)                │       │
    │                                              │       │
    │◄────────────── Idle Timeout ─────────────────────►│  │
    │                (Keep-Alive 유지 시간)                │  │
    │                                                    │  │
    │◄─────────────────── Request Timeout ──────────────────►│
    │                     (전체 요청-응답 시간 제한)             │
```