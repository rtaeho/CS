---
title: "NOT IN 최적화"
tags: [쿼리최적화, 인덱스, SQL]
status: published
---

`NOT IN`은 직관적이고 사용하기 쉬운 부정 조건이지만, 대규모 데이터셋에서는 [[인덱스]]를 거의 활용하지 못해 심각한 성능 저하를 일으킬 수 있습니다.

## 문제점

```sql
SELECT p
FROM Post p
WHERE p.id NOT IN :postIds
```

- 부정 조건이라 대부분의 DBMS가 전체 테이블 스캔이나 인덱스 풀 스캔을 선택합니다. 조건에 맞지 않는 레코드를 걸러내려면 데이터 전체를 훑어야 해서 옵티마이저가 효율적인 실행 계획을 세우기 어렵습니다. ([[인덱스가 안 타는 케이스]] 참고)
- `IN`은 인덱스 Range Scan으로 빠르게 처리되지만, `NOT IN`은 인덱스 활용도가 현저히 떨어집니다.
- `IN` 절에 대량의 값을 넣으면 실행 계획 생성 비용과 파싱·최적화 단계의 오버헤드가 늘어납니다.
- NULL 값 처리 때문에 예상치 못한 결과가 나올 수 있습니다. 예를 들어 `column NOT IN (1, 2, NULL)`은 항상 빈 결과를 반환합니다.

## 최적화 방안

### 1. NOT EXISTS 활용

```sql
SELECT p FROM Post p
WHERE NOT EXISTS (
    SELECT 1 FROM Post temp
    WHERE temp.id = p.id AND temp.id IN :postIds
)
```

`NOT EXISTS`는 행 단위로 평가되어 매칭되는 첫 행을 찾는 즉시 평가를 중단합니다. DBMS가 '존재하지 않음'을 확인하도록 특별히 최적화된 방식이라, 대규모 데이터셋에서도 안정적이고 확장성 있는 성능을 냅니다.

### 2. LEFT JOIN + IS NULL 패턴

```sql
SELECT p FROM Post p
LEFT JOIN (
    SELECT temp.id FROM Post temp WHERE temp.id IN :postIds
) filtered ON p.id = filtered.id
WHERE filtered.id IS NULL
```

서브쿼리 결과가 작을 때 특히 효율적입니다. PK 인덱스를 사용한 JOIN 연산으로 최적화되어 인덱스를 효과적으로 활용할 수 있습니다.

## 핵심 정리

`NOT IN`은 부정 조건 특성상 인덱스를 타기 어려워 대규모 데이터셋에서 풀 스캔을 유발하기 쉽습니다. 같은 의미의 쿼리를 `NOT EXISTS`나 `LEFT JOIN + IS NULL` 패턴으로 바꾸면 인덱스를 활용해 성능을 크게 개선할 수 있습니다.

→ [[NOT IN 쿼리를 사용할 때 발생할 수 있는 문제와 최적화 방법에 대해 설명해 주세요]]
