HTTP 요청/응답을 가로채 공통 처리를 수행하는 두 메커니즘으로, **[[Filter]]는 서블릿 레벨**, **[[Interceptor]]는 Spring MVC 레벨**에서 동작합니다.

## 처리 흐름

```
클라이언트 요청
    ↓
[ Filter ]       ← 서블릿 컨테이너 (Spring 밖)
    ↓
DispatcherServlet
    ↓
[ Interceptor ]  ← Spring MVC (Spring 안)
    ↓
Controller
```

## 비교

| 항목 | [[Filter]] | [[Interceptor]] |
|---|---|---|
| 위치 | 서블릿 컨테이너 (Spring 밖) | Spring MVC (Spring 안) |
| 관리 주체 | Tomcat | DispatcherServlet |
| Spring Bean 주입 | 가능 (`@Component`) | 가능 |
| 요청/응답 변형 | 가능 (바이트 수준) | 제한적 |
| 예외 처리 | `@ControllerAdvice` 불가 | `@ControllerAdvice` 가능 |
| 실행 시점 | before / after | pre / post / afterCompletion |
| 주요 용도 | 보안, 인코딩, CORS | 인증·인가, 로깅, 공통 처리 |

## 언제 뭘 쓰나

**Filter 선택**
- 요청/응답 바이트를 직접 다뤄야 할 때 (압축, 암호화)
- Spring Security처럼 서블릿 전체에 적용할 때
- Spring Context 초기화 전에 처리해야 할 때

**Interceptor 선택**
- Spring Bean(Service 등)이 필요할 때
- Controller 메서드·어노테이션 정보가 필요할 때
- `@ControllerAdvice`와 함께 예외를 일관되게 처리할 때

## 연관 개념

- [[Spring AOP]] — 메서드 레벨 횡단 관심사 (Filter/Interceptor보다 세밀)
- [[Spring Container]] — Interceptor가 Spring Bean으로 관리되는 이유
