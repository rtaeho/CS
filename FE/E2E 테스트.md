사용자의 실제 사용 흐름을 처음부터 끝까지 시뮬레이션하여 시스템 전체가 올바르게 동작하는지 검증하는 테스트입니다.

## 테스트 피라미드에서의 위치

```
        /  E2E 테스트  \        ← 느리고 비용 높음, 적게 작성
       / 통합 테스트     \
      /  단위 테스트       \    ← 빠르고 비용 낮음, 많이 작성
```

## 테스트 종류 비교

| 항목  | 단위 테스트([[유닛 테스트(FE)]]) | 통합 테스트               | E2E 테스트          |
| --- | ---------------------- | -------------------- | ---------------- |
| 범위  | 함수/메서드 단위              | 모듈 간 연동              | 시스템 전체           |
| 속도  | 매우 빠름                  | 보통                   | 느림               |
| 비용  | 낮음                     | 중간                   | 높음               |
| 의존성 | 목(Mock) 처리             | 일부 실제 연동             | 실제 환경(DB, API 등) |
| 예시  | 함수 반환값 검증              | Service + Repository | 회원가입 → 로그인 → 주문  |

## E2E 테스트 예시 시나리오

```
[쇼핑몰 주문 플로우]
1. 사용자가 로그인 페이지에 접속
2. 아이디/비밀번호 입력 후 로그인
3. 상품 목록에서 상품 선택
4. 장바구니에 담기
5. 결제 페이지 이동 후 결제 완료
6. 주문 완료 화면 확인
```

## 대표 도구

|도구|대상|특징|
|---|---|---|
|**Selenium**|웹|다양한 언어 지원, 오래된 표준|
|**Cypress**|웹 (FE 중심)|빠른 실행, 직관적 API|
|**Playwright**|웹|크로스 브라우저, Microsoft 지원|
|**Appium**|모바일|iOS/Android 모두 지원|
|**REST Assured**|API (Java)|Java 기반 API 테스트에 특화|

## Java + Selenium 코드 예시

```java
@Test
void 로그인_후_주문_완료_테스트() {
    WebDriver driver = new ChromeDriver();

    // 1. 로그인
    driver.get("https://example.com/login");
    driver.findElement(By.id("username")).sendKeys("testuser");
    driver.findElement(By.id("password")).sendKeys("password123");
    driver.findElement(By.id("login-btn")).click();

    // 2. 상품 선택 및 장바구니 담기
    driver.findElement(By.className("product-item")).click();
    driver.findElement(By.id("add-to-cart")).click();

    // 3. 결제
    driver.findElement(By.id("checkout-btn")).click();
    driver.findElement(By.id("pay-btn")).click();

    // 4. 주문 완료 확인
    String result = driver.findElement(By.id("order-result")).getText();
    assertEquals("주문이 완료되었습니다.", result);

    driver.quit();
}
```

## 장단점

|장점|단점|
|---|---|
|실제 사용자 관점에서 검증 가능|실행 속도가 느림|
|시스템 전체의 통합 문제 발견|유지보수 비용이 높음|
|배포 전 치명적 버그 방지|테스트 실패 원인 파악이 어려움|
|비개발자도 시나리오 이해 가능|외부 환경에 의한 flaky 테스트 발생|
