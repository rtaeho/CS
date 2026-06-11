Google이 개발한 **HTTP/2 + Protocol Buffers 기반 고성능 RPC(Remote Procedure Call) 프레임워크**입니다.

## 핵심 특징

- **Protocol Buffers**: 바이너리 직렬화 — JSON 대비 작은 크기, 빠른 파싱
- **HTTP/2 기반**: 멀티플렉싱, 헤더 압축, 양방향 스트리밍 지원
- **강타입 계약**: `.proto` 파일로 인터페이스를 정의하고 코드를 자동 생성
- **다언어 지원**: Java, Python, Go, C++, Node.js 등에서 동일 `.proto`로 클라이언트/서버 생성

## .proto 파일 정의

```protobuf
syntax = "proto3";

package post;

service PostService {
    rpc GetPost (PostRequest)          returns (PostResponse);          // Unary
    rpc ListPosts (Empty)              returns (stream PostResponse);  // Server Streaming
    rpc UploadPosts (stream PostRequest) returns (PostResponse);      // Client Streaming
    rpc Chat (stream ChatMessage)      returns (stream ChatMessage);  // Bidirectional
}

message PostRequest  { int64 id = 1; }
message PostResponse { int64 id = 1; string title = 2; string content = 3; }
message Empty {}
message ChatMessage  { string text = 1; }
```

## 4가지 통신 패턴

```
1. Unary (단순 요청-응답)
   Client ──req──→ Server ──res──→ Client

2. Server Streaming (서버가 스트림 응답)
   Client ──req──→ Server ──stream──→──→──→ Client

3. Client Streaming (클라이언트가 스트림 전송)
   Client ──stream──→──→──→ Server ──res──→ Client

4. Bidirectional Streaming (양방향 스트림)
   Client ←──stream──→ Server
```

## Java 구현 예시

```java
// 서버 측 구현
@GrpcService
public class PostServiceImpl extends PostServiceGrpc.PostServiceImplBase {

    @Override
    public void getPost(PostRequest req, StreamObserver<PostResponse> responseObserver) {
        PostResponse res = PostResponse.newBuilder()
            .setId(req.getId())
            .setTitle("제목")
            .build();
        responseObserver.onNext(res);
        responseObserver.onCompleted();
    }
}

// 클라이언트 측 호출
ManagedChannel channel = ManagedChannelBuilder
    .forAddress("localhost", 9090)
    .usePlaintext()
    .build();

PostServiceGrpc.PostServiceBlockingStub stub = PostServiceGrpc.newBlockingStub(channel);
PostResponse res = stub.getPost(PostRequest.newBuilder().setId(1).build());
```

## REST vs gRPC

| | REST | gRPC |
|---|---|---|
| 프로토콜 | HTTP/1.1 | HTTP/2 |
| 직렬화 | JSON (텍스트) | Protocol Buffers (바이너리) |
| 인터페이스 정의 | OpenAPI (선택) | `.proto` (필수) |
| 스트리밍 | SSE / WebSocket 별도 | 기본 제공 |
| 브라우저 지원 | O 직접 지원 | X grpc-web 필요 |
| 성능 | 상대적으로 낮음 | 높음 (바이너리, HTTP/2) |
| 적합한 상황 | 외부 API, 브라우저 통신 | 내부 마이크로서비스 통신 |

## 언제 gRPC를 쓰나

- **마이크로서비스 내부 통신**: 서비스 간 빠른 호출이 필요할 때
- **다언어 환경**: Python AI 서버 ↔ Java 백엔드처럼 언어가 다른 서비스 연결
- **스트리밍**: 양방향 스트리밍이 자연스럽게 필요할 때
- **성능 민감**: 고빈도 호출, 대용량 데이터 전송

## 핵심 정리

- `.proto`로 타입 계약을 정의하고 코드를 자동 생성 — 언어 간 타입 불일치 방지

- JSON 대비 바이너리(Protocol Buffers) + HTTP/2로 속도·용량 모두 유리

- REST는 브라우저 외부 API에, gRPC는 서버 간 내부 통신에 적합

→ [[REST]] | [[HTTP]] | [[TCP]]

