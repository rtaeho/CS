**HTTP를 기반으로 자원을 URL로 표현하고, HTTP 메서드로 행위를 나타내는 아키텍처 스타일**입니다.

## 핵심 원칙

```
1. 자원(Resource)은 URL로 표현
2. 행위는 HTTP 메서드로 표현
3. 응답은 JSON/XML 등으로 표현
```

```
❌ 잘못된 설계          ✅ REST 설계
/getUser/1             GET    /users/1
/createUser            POST   /users
/updateUser/1          PUT    /users/1
/deleteUser/1          DELETE /users/1
```

## HTTP 메서드 역할

|메서드|역할|멱등성|
|---|---|---|
|**GET**|조회|✅|
|**POST**|생성|❌|
|**PUT**|전체 수정|✅|
|**PATCH**|부분 수정|❌|
|**DELETE**|삭제|✅|

> 멱등성: 같은 요청을 여러 번 해도 결과가 동일

## REST 6가지 제약 조건

```
1. Client-Server     : 클라이언트와 서버 분리
2. Stateless         : 서버는 클라이언트 상태 저장 안 함
3. Cacheable         : 응답은 캐시 가능해야 함
4. Uniform Interface : 일관된 인터페이스
5. Layered System    : 계층화된 구조 허용
6. Code on Demand    : 필요 시 클라이언트에 코드 전송 (선택)
```

## Stateless 핵심

```
❌ Stateful
클라이언트: "나 kim이야"
서버: 기억함
클라이언트: "내 정보 줘"
서버: "kim 정보 줘?" (이전 상태 기억)

✅ Stateless (REST)
클라이언트: "나 kim이야, 내 정보 줘" (매 요청마다 정보 포함)
서버: 매 요청을 독립적으로 처리
→ JWT 토큰, API Key 등으로 인증 정보 매 요청에 포함
```

## REST API 설계 규칙

```
✅ 명사 사용          ❌ 동사 사용
/users               /getUsers
/users/1/orders      /getUserOrders

✅ 소문자             ❌ 대문자
/users/profile       /Users/Profile

✅ 하이픈             ❌ 언더스코어
/user-profiles       /user_profiles

✅ 계층 관계 표현
/users/{id}/orders/{orderId}
```

## Spring에서의 REST API

```java
@RestController
@RequestMapping("/users")
public class UserController {

    @GetMapping("/{id}")         // GET /users/1
    public User getUser(@PathVariable Long id) {
        return userService.getUser(id);
    }

    @PostMapping                 // POST /users
    public User createUser(@RequestBody UserRequest request) {
        return userService.create(request);
    }

    @PutMapping("/{id}")         // PUT /users/1
    public User updateUser(@PathVariable Long id,
                           @RequestBody UserRequest request) {
        return userService.update(id, request);
    }

    @DeleteMapping("/{id}")      // DELETE /users/1
    public void deleteUser(@PathVariable Long id) {
        userService.delete(id);
    }
}
```

## REST vs RESTful

```
REST     : 아키텍처 스타일 (개념)
RESTful  : REST 원칙을 잘 준수한 API (구현)

"이 API는 RESTful하다" 
= REST 제약 조건을 잘 지키고 있다는 의미
```

> REST는 **"HTTP를 제대로 활용하자"** 는 아키텍처 스타일입니다. URL은 자원만 표현하고, 행위는 HTTP 메서드로 표현하는 것이 핵심입니다.