**오픈소스 관계형 데이터베이스(RDBMS)**입니다.

---

## 특징

|특징|설명|
|---|---|
|무료|오픈소스 (상용 버전도 있음)|
|SQL 사용|표준 SQL 지원|
|빠름|읽기 성능 좋음|
|대중적|가장 많이 쓰이는 DB 중 하나|

---

## 사용 예

```sql
-- 테이블 생성
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- 데이터 삽입
INSERT INTO users (name, email) VALUES ('철수', 'cs@email.com');

-- 조회
SELECT * FROM users WHERE name = '철수';
```

---

## 다른 RDBMS와 비교

|DB|특징|
|---|---|
|MySQL|무료, 빠름, 대중적|
|PostgreSQL|무료, 기능 풍부, 표준 준수|
|Oracle|유료, 대기업용, 강력한 기능|
|SQL Server|유료, Microsoft, Windows 친화|

---

## 누가 쓰나

```
Facebook, Twitter, YouTube, Netflix, Uber...
```

스타트업부터 대기업까지 널리 사용됩니다.

---

MySQL이 데이터를 찾는 **세 가지 방식**입니다.


## 1. 인덱스 레인지 스캔

**범위를 정해서 필요한 부분만** 읽습니다. 가장 빠릅니다.


```sql
SELECT * FROM users WHERE age BETWEEN 20 AND 30;
```

```
인덱스 (age):
[10] → [15] → [20] → [25] → [30] → [35] → [40]
              ↑ 시작          ↑ 끝
              └── 이 범위만 읽음 ──┘
```

---

## 2. 인덱스 풀 스캔

**인덱스 전체**를 읽습니다.
[[복합 인덱스]]

```sql
-- 복합 인덱스: (A, B, C)
CREATE INDEX idx ON users(A, B, C);

-- A 없이 B로 검색
SELECT * FROM users WHERE B = 'hello';
```

```
인덱스가 A로 정렬되어 있어서 B만으로는 범위 특정 불가
→ 인덱스 전체를 읽으면서 B='hello' 찾음
```

테이블 전체보다는 인덱스가 작으니까 **풀 테이블 스캔보다는 낫습니다.**

---

## 3. 루스 인덱스 스캔

**필요한 부분만 듬성듬성** 읽습니다.

```sql
SELECT dept, MAX(salary) FROM employees GROUP BY dept;
```

```
인덱스 (dept, salary):
[개발팀, 3000]
[개발팀, 4000]
[개발팀, 5000] ← MAX만 필요, 여기만 읽음
[디자인팀, 2500]
[디자인팀, 3500]
[디자인팀, 4500] ← MAX만 필요, 여기만 읽음
```

각 그룹의 첫 번째나 마지막 값만 필요하면 **중간은 건너뜁니다.**

---

## 비교

|스캔 방식|읽는 범위|사용 상황|
|---|---|---|
|인덱스 레인지|필요한 범위만|WHERE 조건이 인덱스와 맞을 때|
|인덱스 풀|인덱스 전체|인덱스 순서와 안 맞을 때|
|루스 인덱스|듬성듬성|GROUP BY, MIN, MAX|

---

## 추가: 랜덤 IO vs 순차 IO

```
인덱스 레인지 스캔 후 실제 데이터 읽기:

인덱스 리프: [PK=5] → [PK=100] → [PK=3]
                ↓         ↓         ↓
데이터 위치:  5번 → 100번 → 3번  (여기저기 점프 = 랜덤 IO)
```

```
풀 테이블 스캔:

테이블: 1번 → 2번 → 3번 → 4번 → ...  (순서대로 = 순차 IO)
```

그래서 데이터의 20-25% 이상을 읽어야 하면, **랜덤 IO보다 순차 IO가 빨라서** 풀 테이블 스캔이 나을 수 있습니다.