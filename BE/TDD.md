테스트 코드를 **먼저 작성한 후 실제 코드를 구현**하는 개발 방법론입니다.

## 핵심 사이클 (Red-Green-Refactor)

```
1. Red    → 실패하는 테스트 작성
2. Green  → 테스트를 통과하는 최소한의 코드 작성
3. Refactor → 코드 개선 (테스트는 여전히 통과)

→ 이 사이클을 반복
```

## 동작 과정

```
[1. Red] 테스트 먼저 작성 → 당연히 실패 💀
@Test
void 두_수의_합() {
    assertEquals(5, calculator.add(2, 3));
}
// Calculator 클래스 없으므로 컴파일 에러

[2. Green] 테스트 통과하는 최소 코드 작성
class Calculator {
    int add(int a, int b) {
        return a + b;  // 테스트 통과 ✅
    }
}

[3. Refactor] 코드 개선
// 중복 제거, 가독성 향상 등
// 테스트는 여전히 통과해야 함 ✅
```

## Java 예시 (JUnit)

```java
// 1. 테스트 먼저 작성
@Test
void 회원가입_이메일_중복_시_예외발생() {
    // given
    String email = "test@test.com";
    userService.join(email);

    // when & then
    assertThrows(DuplicateEmailException.class,
        () -> userService.join(email));  // 중복 가입 시 예외 ✅
}

// 2. 테스트 통과하는 코드 작성
class UserService {
    void join(String email) {
        if (userRepository.existsByEmail(email)) {
            throw new DuplicateEmailException();
        }
        userRepository.save(new User(email));
    }
}
```

## 장단점

|장점|단점|
|---|---|
|버그 조기 발견|초기 개발 속도 느림|
|리팩토링 안정성 확보|테스트 코드 작성 비용|
|설계 품질 향상|학습 곡선 높음|
|명확한 요구사항 정의|모든 상황에 적합하진 않음|

## TDD vs 일반 개발

||일반 개발|TDD|
|---|---|---|
|**순서**|구현 → 테스트|테스트 → 구현|
|**초기 속도**|빠름|느림|
|**장기 유지보수**|어려움|쉬움|
|**설계**|구현 중심|테스트 가능한 설계|

> TDD는 단순한 테스트 기법이 아니라 **설계 방법론**으로, 테스트를 먼저 작성하면 자연스럽게 인터페이스 중심의 설계가 이루어집니다.