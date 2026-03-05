InnoDB에서 테이블의 실제 데이터를 **기본키 순서로 정렬하여 저장하는 인덱스 구조**입니다.

## 클러스터드 인덱스 구조

```
클러스터드 인덱스 (B+Tree)
        [루트 노드]
       /     |      \
  [내부]   [내부]   [내부]
   /  \             /  \
[리프] [리프]   [리프] [리프]
  ↓
실제 데이터가 리프 노드에 직접 저장됨 ← 핵심!
```

## 클러스터드 vs 논-클러스터드

|항목|클러스터드 인덱스|논-클러스터드 인덱스|
|---|---|---|
|**데이터 저장**|인덱스에 실제 데이터 저장|인덱스에 PK 참조값만 저장|
|**테이블당 개수**|1개만 존재 가능|여러 개 가능|
|**조회 성능**|빠름 (1회 탐색)|상대적으로 느림 (2회 탐색)|
|**해당 키**|PRIMARY KEY|일반 INDEX|

## 논-클러스터드 인덱스의 2회 탐색

```
-- email 컬럼에 일반 INDEX가 걸린 경우
SELECT * FROM user WHERE email = 'kim@test.com';

1회: email 인덱스에서 → PK값(id = 1) 찾기
2회: 클러스터드 인덱스에서 → id = 1로 실제 데이터 찾기
```

## Hidden Clustered Index

기본키가 없을 때 InnoDB가 자동 생성하는 **숨겨진 클러스터드 인덱스**입니다.

```
기본키 있음                    기본키 없음
────────────────               ────────────────────────
클러스터드 인덱스              Hidden Clustered Index
= PRIMARY KEY                  = GEN_CLUST_INDEX
  (사용자 접근 가능)             (사용자 접근 불가)
                                6byte ROW_ID 사용
                                전역 카운터 공유 ← 성능 문제
```

```sql
-- ✅ 명시적 PK → 클러스터드 인덱스 = id
CREATE TABLE user (
    id    BIGINT PRIMARY KEY,  -- 이 순서로 데이터 정렬·저장
    email VARCHAR(255)
);

-- ❌ PK 없음 → GEN_CLUST_INDEX 자동 생성
CREATE TABLE user (
    email VARCHAR(255)
);
-- 내부적으로 숨겨진 6byte ROW_ID가 정렬 기준이 됨
```

## 명시적 PK를 써야 하는 이유 (성능 관점)

```sql
-- PK로 조회 → 클러스터드 인덱스 1회 탐색
SELECT * FROM user WHERE id = 1;  -- ✅ 빠름

-- Hidden ROW_ID는 외부 접근 불가
-- → 모든 조회가 Full Scan 위험
SELECT * FROM user WHERE email = 'kim@test.com';  -- ❌ PK 없으면 비효율
```

> InnoDB는 **항상 클러스터드 인덱스 기반으로 동작**하기 때문에, 명시적 PK 선언이 곧 성능 최적화의 시작입니다.