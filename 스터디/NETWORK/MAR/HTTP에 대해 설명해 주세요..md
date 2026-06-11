웹에서 클라이언트와 서버가 데이터를 주고받기 위한 응용 계층(Application Layer)의 통신 프로토콜입니다.

## 기본 동작

```
클라이언트 → [요청 Request]  → 서버
클라이언트 ← [응답 Response] ← 서버
```

## 주요 특징

|특징|설명|
|---|---|
|**무상태 (Stateless)**|각 요청은 독립적, 이전 요청 정보를 저장하지 않음|
|**비연결 (Connectionless)**|요청-응답 후 연결 종료 (HTTP/1.0 기준)|
|**클라이언트-서버 구조**|역할이 명확히 분리됨|

## HTTP 메서드

|메서드|용도|Body|
|---|---|---|
|`GET`|리소스 조회|X|
|`POST`|리소스 생성|O|
|`PUT`|리소스 전체 수정|O|
|`PATCH`|리소스 일부 수정|O|
|`DELETE`|리소스 삭제|X|

## 상태 코드

|범위|의미|예시|
|---|---|---|
|`2xx`|성공|200 OK, 201 Created|
|`3xx`|리다이렉션|301 Moved Permanently|
|`4xx`|클라이언트 오류|400 Bad Request, 401 Unauthorized, 404 Not Found|
|`5xx`|서버 오류|500 Internal Server Error|

## 버전별 비교

|버전|특징|
|---|---|
|**HTTP/1.0**|요청마다 연결/종료|
|**HTTP/1.1**|Keep-Alive로 연결 재사용, 파이프라이닝|
|**HTTP/2**|멀티플렉싱, 헤더 압축, 성능 대폭 향상|
|**HTTP/3**|UDP 기반(QUIC), 더 빠른 연결|

## [[HTTP]] vs [[HTTPS]]

||HTTP|HTTPS|
|---|---|---|
|**암호화**|X|O ([[TLS]]/[[SSL]])|
|**포트**|80|443|
|**보안**|취약|안전|

## Java 예시 (Spring)

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping("/{id}")        // GET /api/users/1
    public UserDto getUser(@PathVariable Long id) { ... }

    @PostMapping               // POST /api/users
    public ResponseEntity<?> createUser(@RequestBody UserDto dto) {
        return ResponseEntity.status(201).body(savedUser);
    }

    @DeleteMapping("/{id}")    // DELETE /api/users/1
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        return ResponseEntity.noContent().build(); // 204
    }
}
```

> **무상태** 특성을 보완하기 위해 **Cookie, Session, Token(JWT)** 등을 활용합니다.