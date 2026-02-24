TCP 연결이 수립된 후 **상대방으로부터 데이터를 수신할 때 지정된 시간 내에 데이터가 도착하지 않으면** 예외를 발생시키는 메커니즘입니다.

## Connection Timeout과의 차이

```
[Connection Timeout — 연결 단계]
클라이언트 ── SYN ──→ 서버 (응답 없음)
    → "연결 자체가 안 됨"

[Read Timeout — 데이터 수신 단계]
클라이언트 ←─ SYN-ACK ─→ 서버    ← 연결은 성공
클라이언트 ── HTTP 요청 ──→ 서버
클라이언트 ← ... 응답 없음 ...     ← 데이터가 안 옴
    → "연결은 됐지만 응답이 안 옴"
```

|항목|Connection Timeout|Read Timeout|
|---|---|---|
|**발생 시점**|TCP 3-Way Handshake|연결 수립 후 데이터 수신|
|**TCP 상태**|SYN_SENT|ESTABLISHED|
|**의미**|서버와 연결 불가|서버가 응답을 안 보냄|
|**대표 원인**|서버 다운, 방화벽 차단|서버 과부하, 느린 쿼리|

## Read Timeout 발생 시나리오

```
클라이언트                                서버
    │                                     │
    │──── SYN ──────────────────→         │
    │←─── SYN-ACK ──────────────         │
    │──── ACK ──────────────────→         │  연결 수립 완료
    │                                     │
    │──── HTTP GET /api/data ───→         │
    │                                     │  서버가 처리 중...
    │     ... 1초 경과 ...                 │  DB 쿼리 실행 중...
    │     ... 2초 경과 ...                 │  아직 처리 중...
    │     ... 3초 경과 ...                 │  아직 처리 중...
    │     ... 4초 경과 ...                 │  아직 처리 중...
    │     ... 5초 경과 (Read Timeout) ...  │
    │                                     │
    ✕ SocketTimeoutException:             │
      "Read timed out"                    │
```

## Read Timeout이 발생하는 원인

|원인|설명|
|---|---|
|**서버 과부하**|요청이 몰려서 처리가 지연됨|
|**느린 DB 쿼리**|복잡한 조인, 풀스캔 등으로 응답 지연|
|**대용량 데이터 처리**|큰 파일 생성, 대량 데이터 가공|
|**외부 API 의존**|서버가 다른 서비스 응답을 기다리는 중|
|**데드락**|서버 스레드가 교착 상태에 빠짐|
|**GC Pause**|서버 JVM의 Full GC로 일시 정지|
|**네트워크 지연**|응답 패킷이 네트워크에서 지연되거나 유실|

```
[서버 내부에서 지연 발생 예시]

클라이언트 요청 → 서버 수신
                   │
                   ▼
              서버 비즈니스 로직
                   │
                   ├── DB 쿼리 (3초 소요)
                   │
                   ├── 외부 API 호출 (응답 대기 중...)
                   │
                   └── 결과 조합 후 응답 생성
                        │
                        ▼
                   응답 전송 → 하지만 이미 클라이언트는 Timeout
```

## Read Timeout 주의사항

### 데이터 일부만 수신된 경우

Read Timeout은 **마지막 데이터 수신 이후** 다음 데이터가 올 때까지의 시간을 측정합니다. 전체 응답 시간이 아닙니다.

```
[Read Timeout = 5초 설정]

시나리오 1: Timeout 발생 안 함 (총 15초 걸려도)
  0초  → 데이터 청크 1 수신
  4초  → 데이터 청크 2 수신 (4초 < 5초 → OK)
  8초  → 데이터 청크 3 수신 (4초 < 5초 → OK)
  12초 → 데이터 청크 4 수신 (4초 < 5초 → OK)
  15초 → 수신 완료

시나리오 2: Timeout 발생 (총 7초에 발생)
  0초  → 데이터 청크 1 수신
  2초  → 데이터 청크 2 수신
  7초  → 5초 동안 데이터 없음 → Read Timeout 발생!
```

```
⚠ Read Timeout ≠ 전체 응답 시간 제한

  Read Timeout은 "청크 간 간격"을 측정
  전체 응답 시간을 제한하려면 별도의 Request Timeout 필요
```

## Java에서의 Read Timeout 설정

### 1. 순수 Socket

```java
Socket socket = new Socket();
socket.connect(new InetSocketAddress("example.com", 80), 3000);
socket.setSoTimeout(5000);  // ★ Read Timeout: 5초

try {
    InputStream in = socket.getInputStream();
    int data = in.read();  // 5초 내에 데이터 없으면 예외
} catch (SocketTimeoutException e) {
    System.out.println("Read timed out: " + e.getMessage());
}
```

### 2. HttpURLConnection

```java
HttpURLConnection conn = (HttpURLConnection) new URL("https://example.com").openConnection();
conn.setConnectTimeout(3000);
conn.setReadTimeout(5000);  // ★ Read Timeout: 5초

try {
    BufferedReader br = new BufferedReader(
        new InputStreamReader(conn.getInputStream())
    );
    String line = br.readLine();
} catch (SocketTimeoutException e) {
    System.out.println("응답 수신 시간 초과");
}
```

### 3. Spring RestTemplate

```java
SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
factory.setConnectTimeout(3000);
factory.setReadTimeout(5000);  // ★ Read Timeout: 5초

RestTemplate restTemplate = new RestTemplate(factory);

try {
    String result = restTemplate.getForObject("/api/data", String.class);
} catch (ResourceAccessException e) {
    System.out.println("요청 실패: " + e.getMessage());
}
```

### 4. Spring WebClient

```java
HttpClient httpClient = HttpClient.create()
    .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 3000)
    .responseTimeout(Duration.ofSeconds(5));  // ★ Read Timeout: 5초

WebClient webClient = WebClient.builder()
    .clientConnector(new ReactorClientHttpConnector(httpClient))
    .build();

webClient.get()
    .uri("/api/data")
    .retrieve()
    .bodyToMono(String.class)
    .timeout(Duration.ofSeconds(10))  // 전체 Request Timeout
    .subscribe();
```

## Read Timeout 발생 시 서버 측 상태

```
클라이언트: Read Timeout 발생 → 연결 끊기 (FIN 또는 RST)

서버 측:
  ├── 요청 처리 중이었다면?
  │    → 서버는 처리를 계속하고 있을 수 있음
  │    → 응답을 보내려고 할 때 "Broken Pipe" 에러 발생
  │    → 리소스 낭비 (이미 클라이언트는 떠남)
  │
  └── DB 쿼리 중이었다면?
       → 쿼리는 DB에서 계속 실행될 수 있음
       → 별도의 쿼리 타임아웃 설정 필요

⚠ 클라이언트 Timeout ≠ 서버 작업 취소
   → 서버/DB에도 별도 Timeout 설정 필요
```

## Timeout 설정 가이드

|환경|Read Timeout 권장|이유|
|---|---|---|
|**내부 서비스**|3~5초|빠른 응답이 기대됨|
|**외부 API**|5~30초|외부 의존성은 느릴 수 있음|
|**DB 쿼리**|쿼리에 따라 다름|복잡한 쿼리는 길게 설정|
|**파일 다운로드**|30~120초|대용량 전송에 시간 소요|
|**배치 처리**|60~300초|장시간 작업|

## 전체 Timeout 체계에서의 위치

```
클라이언트                                       서버
    │                                            │
    │◄── Connection Timeout ──►│                 │
    │   (연결 수립 단계)          │                 │
    │                           │                 │
    │──── 요청 전송 ────────────→│                 │
    │                           │                 │
    │◄──── Read Timeout ────────────────►│        │
    │      (응답 대기 단계)                │        │
    │      ★ 청크 간 간격 측정             │        │
    │                                    │        │
    │◄──────── Request Timeout ──────────────────►│
    │          (전체 요청-응답 시간 제한)             │
```
