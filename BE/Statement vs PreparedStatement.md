---
title: "Statement vs PreparedStatement"
tags: [JDBC, SQL, 보안]
status: published
---

[[JDBC]]에서 SQL을 실행하는 두 방식으로, SQL을 매번 문자열로 조합하는 **Statement**와 파라미터를 바인딩해 실행하는 **PreparedStatement**로 나뉘며 보안·성능 측면에서 차이가 있습니다.

## 동작 방식

**Statement**는 SQL을 문자열 그대로 전달하고 매번 새로 파싱·컴파일합니다.

```java
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery("select * from users where age > 30");
```

**PreparedStatement**는 `?` 플레이스홀더로 쿼리 구조를 먼저 확정한 뒤 값을 바인딩합니다.

```java
String sql = "select * from users where age > ?";
PreparedStatement pstmt = conn.prepareStatement(sql);
pstmt.setInt(1, 30);
ResultSet rs = pstmt.executeQuery();
```

## 비교

| 항목 | Statement | PreparedStatement |
|---|---|---|
| SQL 구성 | 문자열 연결(동적) | 플레이스홀더 + 바인딩 |
| [[SQL 인젝션]] | 취약 | 값이 이스케이프 처리되어 방지 |
| 실행 계획 캐싱 | 매번 새로 파싱 | 캐싱되어 반복 실행 시 유리 |
| 반복 실행 성능 | 상대적으로 낮음 | 상대적으로 높음 |

## 왜 PreparedStatement가 더 안전한가

값을 바인딩하는 시점에 내부적으로 이스케이프 처리를 하기 때문에, 사용자 입력이 쿼리 구조 자체를 바꾸지 못합니다. 그래서 [[SQL 인젝션]] 공격을 방지할 수 있습니다.

## 왜 PreparedStatement가 더 빠른가

쿼리 구조를 미리 확정하고 플레이스홀더로 값만 바꿔 끼우기 때문에, SQL 구문 분석 결과를 캐싱할 수 있습니다. 같은 쿼리를 반복 실행할 때 Statement보다 성능이 높은 것으로 알려져 있습니다.

## 핵심 정리

Statement는 SQL을 문자열로 직접 조합해 SQL 인젝션에 취약하고 매번 파싱 비용이 발생하는 반면, PreparedStatement는 파라미터 바인딩으로 보안성과 반복 실행 성능을 모두 확보할 수 있습니다.

→ [[Statement와 PreparedStatement의 차이점은 무엇인가요?]]
