Elasticsearch는 대량의 데이터를 **실시간으로 검색하고 분석할 수 있는 분산형 검색 엔진**으로, 역색인(Inverted Index) 구조를 기반으로 빠른 전문 검색(Full-Text Search)을 제공합니다.

## 왜 필요한가

```
[일반 DB 검색의 한계]
SELECT * FROM products WHERE name LIKE '%무선 블루투스 이어폰%';

→ LIKE '%...%' 는 인덱스를 활용하지 못함 → Full Table Scan
→ 데이터가 수백만 건이면 수 초~수십 초 소요
→ "블루투스 무선 이어폰" (어순 변경) → 검색 안 됨 ❌
→ "이어폰 블루투스" (부분 단어) → 검색 안 됨 ❌
→ 오타 보정, 유의어 검색 불가

[Elasticsearch]
GET /products/_search
{"query": {"match": {"name": "블루투스 무선 이어폰"}}}

→ 역색인 기반 → 밀리초 단위 응답
→ 어순 무관하게 검색 가능 ✅
→ 유사 단어, 오타 보정 가능 ✅
```

## 핵심 개념 — 역색인 (Inverted Index)

일반 DB는 문서 → 단어 방향으로 저장하지만, Elasticsearch는 **단어 → 문서** 방향으로 저장합니다.

```
[일반 DB — 정방향 인덱스]
문서1: "무선 블루투스 이어폰"
문서2: "블루투스 스피커"
문서3: "무선 마우스"

→ "블루투스" 검색 시 모든 문서를 하나씩 확인해야 함

[Elasticsearch — 역색인]
"무선"     → [문서1, 문서3]
"블루투스"  → [문서1, 문서2]
"이어폰"   → [문서1]
"스피커"   → [문서2]
"마우스"   → [문서3]

→ "블루투스" 검색 시 → 즉시 [문서1, 문서2] 반환
→ "무선 블루투스" 검색 시 → 교집합 [문서1] 반환
→ 데이터가 아무리 많아도 빠름
```

## 기본 구조 — RDBMS와 비교

|RDBMS|Elasticsearch|설명|
|---|---|---|
|Database|Index|데이터 저장 단위|
|Table|Type (7.x 이후 폐지)|문서 분류|
|Row|Document|하나의 데이터 레코드|
|Column|Field|데이터 항목|
|Schema|Mapping|필드 타입 정의|
|SQL|Query DSL|검색 문법|

```json
// Elasticsearch Document 예시
{
    "_index": "products",
    "_id": "1",
    "_source": {
        "name": "무선 블루투스 이어폰",
        "price": 45000,
        "category": "전자기기",
        "description": "고품질 무선 블루투스 이어폰입니다"
    }
}
```

## 기본 CRUD 예시

```http
// 문서 생성 (인덱싱)
PUT /products/_doc/1
{
    "name": "무선 블루투스 이어폰",
    "price": 45000,
    "category": "전자기기"
}

// 문서 조회
GET /products/_doc/1

// 문서 검색
GET /products/_search
{
    "query": {
        "match": {
            "name": "블루투스 이어폰"
        }
    }
}

// 문서 수정
POST /products/_update/1
{
    "doc": {
        "price": 39000
    }
}

// 문서 삭제
DELETE /products/_doc/1
```

## 검색 기능

### 전문 검색 (Full-Text Search)

```http
// match — 형태소 분석 후 검색 (기본)
GET /products/_search
{
    "query": {
        "match": {
            "name": "무선 이어폰"
        }
    }
}
// → "무선", "이어폰" 각각으로 분리 → 하나라도 포함되면 검색

// match_phrase — 어순 일치 검색
GET /products/_search
{
    "query": {
        "match_phrase": {
            "name": "무선 블루투스"
        }
    }
}
// → "무선 블루투스"가 연속으로 나오는 문서만 검색

// fuzzy — 오타 보정 검색
GET /products/_search
{
    "query": {
        "fuzzy": {
            "name": {
                "value": "블루투쓰",
                "fuzziness": 1
            }
        }
    }
}
// → "블루투스"도 검색됨 (편집 거리 1 이내)
```

### 복합 검색

```http
GET /products/_search
{
    "query": {
        "bool": {
            "must": [
                {"match": {"name": "블루투스 이어폰"}}
            ],
            "filter": [
                {"range": {"price": {"lte": 50000}}},
                {"term": {"category": "전자기기"}}
            ]
        }
    },
    "sort": [
        {"price": "asc"}
    ]
}
// → 이름에 "블루투스 이어폰" 포함
// → 가격 5만원 이하
// → 카테고리가 "전자기기"
// → 가격 오름차순 정렬
```

## 분산 구조

```
                    ┌─────────────────────┐
                    │   Elasticsearch     │
                    │     Cluster         │
                    └────────┬────────────┘
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
         ┌─────────┐   ┌─────────┐   ┌─────────┐
         │ Node 1  │   │ Node 2  │   │ Node 3  │
         │(Master) │   │         │   │         │
         ├─────────┤   ├─────────┤   ├─────────┤
         │ Shard 0 │   │ Shard 1 │   │ Shard 2 │
         │(Primary)│   │(Primary)│   │(Primary)│
         │ Shard 1 │   │ Shard 2 │   │ Shard 0 │
         │(Replica)│   │(Replica)│   │(Replica)│
         └─────────┘   └─────────┘   └─────────┘

- 데이터를 Shard 단위로 분할하여 분산 저장
- 각 Shard의 Replica를 다른 노드에 배치 → 장애 대응
- 노드 추가만으로 수평 확장(Scale-Out) 가능
```

## Java(Spring Boot) 연동 예시

```java
// build.gradle
implementation 'org.springframework.boot:spring-boot-starter-data-elasticsearch'
```

```java
// Document 정의
@Document(indexName = "products")
public class ProductDocument {

    @Id
    private String id;

    @Field(type = FieldType.Text, analyzer = "nori")  // 한국어 형태소 분석기
    private String name;

    @Field(type = FieldType.Integer)
    private int price;

    @Field(type = FieldType.Keyword)
    private String category;
}
```

```java
// Repository
public interface ProductSearchRepository
        extends ElasticsearchRepository<ProductDocument, String> {

    List<ProductDocument> findByName(String name);
    List<ProductDocument> findByPriceBetween(int min, int max);
}
```

```java
// Service — 복잡한 검색
@Service
@RequiredArgsConstructor
public class ProductSearchService {

    private final ElasticsearchOperations operations;

    public List<ProductDocument> search(String keyword, int maxPrice) {
        NativeQuery query = NativeQuery.builder()
                .withQuery(q -> q
                    .bool(b -> b
                        .must(m -> m.match(mt -> mt.field("name").query(keyword)))
                        .filter(f -> f.range(r -> r.field("price").lte(JsonData.of(maxPrice))))
                    )
                )
                .build();

        SearchHits<ProductDocument> hits = operations.search(query, ProductDocument.class);
        return hits.getSearchHits().stream()
                .map(SearchHit::getContent)
                .collect(Collectors.toList());
    }
}
```

## RDBMS + Elasticsearch 병행 구조

실무에서는 Elasticsearch를 DB 대체가 아닌 **검색 전용 계층**으로 함께 사용합니다.

```
[일반적인 아키텍처]
                  쓰기                     읽기(검색)
클라이언트 ──→ API 서버 ──→ MySQL        클라이언트 ──→ API 서버 ──→ Elasticsearch
                   │
                   └──→ Elasticsearch (동기화)

- MySQL: 원본 데이터 저장 (트랜잭션, 정합성)
- Elasticsearch: 검색용 인덱스 (빠른 전문 검색)
- 데이터 동기화: 이벤트 기반 또는 배치로 MySQL → Elasticsearch 반영
```

## RDBMS vs Elasticsearch 비교

|항목|RDBMS|Elasticsearch|
|---|---|---|
|**검색 속도**|LIKE 검색 느림|역색인 기반 밀리초 응답|
|**전문 검색**|제한적|형태소 분석, 유의어, 오타 보정|
|**트랜잭션**|ACID 보장 ✅|미지원 ❌|
|**정합성**|강한 정합성|근실시간 (Near Real-Time)|
|**JOIN**|지원 ✅|미지원 (비정규화로 해결)|
|**용도**|데이터 저장/관리|검색/분석|

## 면접 포인트

- Elasticsearch의 핵심은 **역색인(Inverted Index)** 구조이며, 이를 통해 RDBMS의 LIKE 검색 대비 압도적으로 빠른 전문 검색이 가능합니다.
- 실무에서는 RDBMS를 대체하는 것이 아니라, **RDBMS는 원본 데이터 저장, Elasticsearch는 검색 전용**으로 병행하여 사용합니다.
- Elasticsearch는 트랜잭션과 강한 정합성을 지원하지 않으므로, **데이터 동기화 전략(이벤트 기반, CDC, 배치 등)**에 대한 설계가 함께 필요합니다.