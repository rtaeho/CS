**JDBC(Java Database Connectivity)**는 Java에서 데이터베이스에 접속할 수 있게 해주는 **표준 API**입니다.

## 한마디로

Java 애플리케이션과 DB 사이의 **다리** 역할을 하는 가장 기본적인 기술이에요.

## 동작 방식

```
Java 애플리케이션 → JDBC API → JDBC 드라이버 → 데이터베이스
```

각 DB [[벤더]](MySQL, Oracle, PostgreSQL 등)가 자신의 DB에 맞는 JDBC 드라이버를 제공합니다.

## 기본 사용 예시

```java
// 1. 드라이버 로드 & 연결
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/mydb", "user", "password"
);

// 2. SQL 실행
PreparedStatement stmt = conn.prepareStatement(
    "SELECT * FROM users WHERE id = ?"
);
stmt.setInt(1, 1);
ResultSet rs = stmt.executeQuery();

// 3. 결과 처리
while (rs.next()) {
    String name = rs.getString("name");
    System.out.println(name);
}

// 4. 자원 해제
rs.close();
stmt.close();
conn.close();
```

## Hibernate와의 관계

|구분|JDBC|Hibernate|
|---|---|---|
|레벨|저수준 API|고수준 ORM|
|SQL|직접 작성|자동 생성|
|코드량|많음|적음|
|학습 난이도|낮음|높음|

**Hibernate도 내부적으로는 JDBC를 사용합니다.** 즉, Hibernate는 JDBC를 더 편하게 쓸 수 있도록 감싸놓은 것이라고 보면 됩니다.

## 현업에서는?

순수 JDBC를 직접 쓰는 경우는 드물고, 보통 이런 식으로 사용합니다:

- **Spring Data JPA + Hibernate** (가장 일반적)
- **MyBatis** (SQL을 직접 관리하고 싶을 때)
- **JdbcTemplate** (Spring에서 JDBC를 조금 더 편하게 쓰고 싶을 때)