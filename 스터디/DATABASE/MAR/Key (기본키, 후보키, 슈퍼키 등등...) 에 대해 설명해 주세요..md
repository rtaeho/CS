릴레이션에서 튜플을 식별하거나 관계를 표현하기 위해 사용하는 속성(또는 속성의 집합)입니다.

## 키 계층 구조

```
슈퍼키 (Super Key)
└── 후보키 (Candidate Key)
    ├── 기본키 (Primary Key)
    │   └── 대리키 (Surrogate Key)  ← 기본키의 구현 방식
    └── 대체키 (Alternate Key)

외래키 (Foreign Key) ← 별도 개념
```

## 키 종류 정리

|키|유일성|최소성|NULL|설명|
|---|---|---|---|---|
|**슈퍼키**|✅|❌|-|튜플을 유일하게 식별할 수 있는 **모든** 속성 집합|
|**후보키**|✅|✅|-|슈퍼키 중 최소한의 속성만으로 구성된 키|
|**기본키**|✅|✅|❌|후보키 중 대표로 선택된 키|
|**대체키**|✅|✅|-|후보키 중 기본키로 선택되지 않은 나머지 키|
|**대리키**|✅|✅|❌|식별을 위해 **인위적으로 생성**한 기본키|
|**외래키**|❌|❌|-|다른 테이블의 기본키를 참조하는 속성|

## 유일성 vs 최소성

- **유일성**: 하나의 키 값으로 튜플을 **하나만** 식별 가능
- **최소성**: 꼭 필요한 속성만으로 구성 (속성 하나를 제거하면 유일성 깨짐)

## 예시

학생 테이블 `(학번, 주민번호, 이름, 학과)`

```
슈퍼키    : {학번}, {주민번호}, {학번, 이름}, {학번, 주민번호}, ...
후보키    : {학번}, {주민번호}           ← 최소성 만족
기본키    : {학번}                       ← 후보키 중 선택, NOT NULL + UNIQUE
대체키    : {주민번호}                   ← 선택받지 못한 후보키
```

## 자연키 vs 대리키

|항목|자연키 (Natural Key)|대리키 (Surrogate Key)|
|---|---|---|
|정의|데이터 자체 속성 사용|인위적으로 생성한 식별자|
|예시|주민번호, 이메일, 학번|AUTO_INCREMENT, UUID|
|변경 가능성|있음|거의 없음|
|비즈니스 의미|있음|없음|
|실무 사용|드묾|매우 흔함|

## 대리키 종류

|종류|예시|특징|
|---|---|---|
|**AUTO_INCREMENT**|1, 2, 3 ...|단순, 순서 있음, 분산 환경에 취약|
|**UUID**|`550e8400-e29b-41d4...`|전역 유일, 분산 환경에 강함, 인덱스 비효율|
|**ULID / Snowflake**|Twitter Snowflake 등|시간 정렬 가능 + 유일성 보장|

## 코드 예시

```java
// ❌ 자연키 사용 시 문제
// 이메일 변경 시 FK 참조 테이블 전부 영향
@Entity
public class User {
    @Id
    private String email;
}

// ✅ 대리키 + 대체키 활용 (실무 권장)
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;          // 대리키 (기본키)

    @Column(unique = true)
    private String email;     // 대체키
}

// 외래키 참조
@Entity
public class Enrollment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")  // 외래키
    private User user;
}
```