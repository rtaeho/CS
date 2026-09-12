---
title: "SQL 인젝션"
tags: [보안, SQL, 데이터베이스]
status: published
---

공격자가 사용자 입력값을 조작해 SQL 쿼리의 구조를 변경시켜 인증을 우회하거나 데이터를 탈취·조작하는 보안 취약점이다.

## 발생 원인

사용자 입력을 문자열로 그대로 이어붙여 쿼리를 생성할 때 발생한다.

```java
String sql = "SELECT * FROM users WHERE username = '" + username + "' AND password = '" + password + "'";
```

`username`에 `admin' --`를 입력하면 비밀번호 조건이 주석 처리되어 인증 없이 조회된다.

```sql
SELECT * FROM users WHERE username = 'admin' -- ' AND password = '...';
```

## 대표적인 공격 패턴

- `' OR '1'='1`: 항상 참이 되는 조건으로 인증 우회
- `' UNION SELECT * FROM accounts --`: 다른 테이블 정보 조회
- `'; DROP TABLE users; --`: 테이블 삭제

## 방어 방법

- **PreparedStatement**: place holder(`?`)에 값을 바인딩해 내부적으로 이스케이프 처리하므로 입력값이 쿼리 구조에 영향을 줄 수 없다. [[JDBC]]의 `PreparedStatement`가 대표적이다.
- **ORM 사용**: [[JPA]], [[Hibernate]]처럼 SQL을 직접 작성하지 않는 ORM을 사용하면 인젝션 위험이 줄어든다.
- **입력값 검증**: 공격에 사용되는 SQL 구문 포함 여부를 검증한다.
- **최소 권한 원칙**: 웹 애플리케이션이 사용하는 DB 계정에 필요한 최소한의 권한만 부여한다.
- **에러 메시지 은닉**: SQL 오류나 예외 메시지를 사용자에게 직접 노출하지 않는다.

## [[XSS]], [[CSRF]]와의 차이

XSS는 브라우저에서 악성 스크립트를 실행시키고 CSRF는 인증된 브라우저의 요청을 악용하지만, SQL 인젝션은 애플리케이션과 데이터베이스 사이의 쿼리 생성 로직을 조작해 데이터베이스에 직접 영향을 미친다는 차이가 있다.

## 핵심 정리

SQL 인젝션은 사용자 입력이 SQL 쿼리 문자열에 그대로 결합될 때 발생하며, PreparedStatement로 값을 바인딩하거나 ORM을 사용하면 대부분 방지할 수 있다.

→ [[SQL 인젝션에 대해 설명해 주세요.]]
