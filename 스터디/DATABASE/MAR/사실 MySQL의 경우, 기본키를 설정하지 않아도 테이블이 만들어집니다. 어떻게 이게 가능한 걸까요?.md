[[MySQL]]이 기본키가 없어도 내부적으로 **숨겨진 클러스터드 인덱스([[Hidden Clustered Index]])** 를 자동 생성하기 때문입니다.

## InnoDB의 기본키 결정 순서

```
1순위: 사용자가 명시한 PRIMARY KEY
        ↓ 없으면
2순위: NOT NULL + UNIQUE 컬럼 중 첫 번째
        ↓ 없으면
3순위: 내부적으로 숨겨진 6바이트 RowID 자동 생성 (GEN_CLUST_INDEX)
```

## GEN_CLUST_INDEX란?

```sql
-- 기본키 없이 테이블 생성
CREATE TABLE no_pk (
    name VARCHAR(100),
    email VARCHAR(100)
);

-- 사용자 눈에는 보이지 않지만 내부적으로 아래와 같이 동작
-- ROW_ID (6byte, 전역 카운터) 가 숨겨진 PK 역할
```

```
┌──────────────────────────────────┐
│  숨겨진 ROW_ID  │  name  │  email │
│  (6byte)        │        │        │
├─────────────────┼────────┼────────┤
│  000001         │  kim   │  a@..  │
│  000002         │  lee   │  b@..  │
└──────────────────────────────────┘
```

## 명시적 PK가 없을 때의 문제점

|문제|설명|
|---|---|
|**ROW_ID 전역 공유**|모든 PK 없는 테이블이 하나의 카운터 공유 → 경합 발생|
|**복제 위험**|ROW_ID는 복제(Replication) 시 전달되지 않아 Row 식별 불가|
|**성능 저하**|외부에서 ROW_ID 접근 불가 → 인덱스 활용 어려움|
|**파티셔닝 불가**|PK 없으면 파티셔닝 설정 불가|

## 확인 방법

```sql
-- 실제 인덱스 확인
SHOW INDEX FROM no_pk;
-- 결과: 아무것도 안 나옴 (숨겨진 인덱스는 노출 안 됨)

-- InnoDB 내부 상태 확인
SELECT * FROM information_schema.INNODB_INDEXES
WHERE NAME = 'GEN_CLUST_INDEX';
```

## 결론

> MySQL이 PK 없이도 테이블을 만들 수 있는 건 InnoDB가 **자동으로 숨겨진 키를 만들어주기 때문**입니다. 하지만 이는 성능/복제/안정성 측면에서 문제가 생기므로, **항상 명시적 기본키를 선언하는 것이 원칙**입니다.
