**벡터 검색으로 관련 문서를 검색한 뒤 LLM에 컨텍스트로 제공해 답변 정확도를 높이는 기법**입니다 (Retrieval-Augmented Generation).

## 왜 필요한가

LLM의 한계:
- **지식 컷오프**: 학습 데이터 이후의 최신 정보 모름
- **할루시네이션**: 없는 내용을 그럴듯하게 생성
- **도메인 지식 부족**: 내부 문서, 사내 데이터를 모름

RAG는 **검색된 실제 문서를 근거로** 답변을 생성하게 해 이 문제를 완화.

## 전체 흐름

```
[ 인덱싱 단계 (오프라인) ]

원본 문서 (PDF, hwpx, txt ...)
      │
      ▼
  청킹 (Chunking)
  → 긴 문서를 적절한 크기의 조각으로 분할
      │
      ▼
  임베딩 모델 (BGE-M3, OpenAI Ada ...)
  → 각 청크를 고차원 벡터로 변환
      │
      ▼
  Vector DB 저장 (Chroma, Pinecone ...)


[ 검색·생성 단계 (런타임) ]

사용자 질문
      │
      ▼
  임베딩 모델로 질문 벡터화
      │
      ▼
  Vector DB 유사도 검색 → Top-K 청크 반환
      │
      ▼
  프롬프트 구성: 질문 + 검색된 청크 (컨텍스트)
      │
      ▼
  LLM 생성 → 최종 답변
```

## 청킹 전략

```
고정 크기 청킹: 500토큰마다 분할, 오버랩 50토큰
  → 단순, 문맥 잘림 위험

문서 구조 기반: 단락, 섹션 단위 분할
  → 의미 단위 유지, 문서마다 크기 다름

재귀적 청킹: 문단 → 문장 → 단어 순으로 분할
  → LangChain4j의 RecursiveCharacterTextSplitter
```

## 임베딩 모델

| 모델 | 특징 |
|---|---|
| BGE-M3 | 다국어 지원, 오픈소스, 온프레미스 운용 가능 |
| OpenAI text-embedding-3 | 성능 우수, API 비용 발생 |
| KoSimCSE | 한국어 특화 |

## Naive RAG vs Advanced RAG

| | Naive RAG | Advanced RAG |
|---|---|---|
| 검색 | 단순 유사도 Top-K | 하이브리드 검색 (벡터 + BM25 키워드) |
| 재순위 | 없음 | Reranker 모델로 재정렬 |
| 청킹 | 고정 크기 | 의미 단위, 계층적 |
| 질문 처리 | 원본 질문 그대로 | 질문 확장/분해 (HyDE, Multi-Query) |

## LangChain4j로 구현 (Java)

```java
// 문서 임베딩 및 저장
EmbeddingModel embeddingModel = new BgeSmallEnEmbeddingModel();
EmbeddingStore<TextSegment> store = new InMemoryEmbeddingStore<>();

TextSegment segment = TextSegment.from("Spring WebFlux는 논블로킹 프레임워크입니다.");
Embedding embedding = embeddingModel.embed(segment).content();
store.add(embedding, segment);

// 검색
Embedding queryEmbedding = embeddingModel.embed("WebFlux란?").content();
List<EmbeddingMatch<TextSegment>> matches = store.findRelevant(queryEmbedding, 3);
```

## 핵심 정리

- LLM의 지식 한계를 보완 — 학습 데이터 외 내부 문서·최신 정보를 근거로 답변 생성

- 인덱싱(오프라인)과 검색·생성(런타임) 두 단계로 구분됨

- 청킹 품질과 임베딩 모델 선택이 RAG 성능의 핵심

→ [[Vector DB]] | [[LangChain4j]]
