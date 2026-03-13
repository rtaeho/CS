**애플리케이션 간에 데이터와 기능을 주고받기 위한 통신 규약(인터페이스)**입니다.

## 핵심 개념

```
API = Application Programming Interface

"내가 제공하는 기능을 이렇게 호출하면 돼" 라는 약속

식당으로 비유
손님(클라이언트) → 메뉴판(API) → 주방(서버)
손님은 요리 방법을 몰라도 메뉴만 보고 주문 가능
```

## API가 없다면?

```
❌ API 없이 DB 직접 접근
클라이언트 → DB 직접 접근
→ 보안 위험, DB 구조 노출, 클라이언트마다 쿼리 작성

✅ API를 통한 접근
클라이언트 → API → 서버 → DB
→ 내부 구현 숨김, 보안 유지, 일관된 인터페이스
```

## 종류

|종류|설명|예시|
|---|---|---|
|**REST API**|HTTP 기반 자원 중심|대부분의 웹 서비스|
|**GraphQL**|클라이언트가 원하는 데이터만 요청|GitHub, Meta|
|**gRPC**|바이너리 기반 고성능 통신|마이크로서비스 간|
|**WebSocket**|양방향 실시간 통신|채팅, 주식|

## REST API 예시

```java
// 서버가 API 제공
@RestController
@RequestMapping("/users")
public class UserController {

    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.getUser(id);
    }
}

// 클라이언트가 API 호출
GET https://api.example.com/users/1

// 응답 (JSON)
{
    "id": 1,
    "name": "kim",
    "email": "kim@test.com"
}
```

## API 호출 흐름

```
클라이언트                서버
    │                      │
    │── GET /users/1 ──→   │
    │                      │ DB 조회
    │← 200 OK {user} ───   │
    │                      │
```

## Public API vs Private API

```
Public API  : 외부 공개 (카카오 로그인, 구글 지도 API)
Private API : 내부 전용 (마이크로서비스 간 통신)
Partner API : 특정 파트너에게만 공개
```

> API는 **"내부 구현을 숨기고 정해진 방법으로만 소통하게 하는 창구"** 입니다. 클라이언트는 서버 내부를 몰라도, API 명세만 알면 기능을 사용할 수 있습니다.