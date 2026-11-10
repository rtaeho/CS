---
title: "RAG"
tags: [LangChain4j, 임베딩]
status: published
---

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

## RAG의 한계와 Contextual Retrieval

문서를 청크 단위로 쪼개면 청크 하나만 봐서는 맥락을 알 수 없는 문제가 생긴다. 예를 들어 "매출이 3% 올랐다"는 청크만 보면 어느 회사, 어느 시기의 이야기인지 알 수 없어 검색에 걸리지 않거나 잘못 쓰일 수 있다. 임베딩만 쓰면 "TS-999"처럼 정확히 일치해야 하는 코드·용어도 놓치기 쉽다.

앤트로픽은 Contextual Retrieval이라는 기법으로 이를 완화했다. 각 청크를 임베딩·BM25 인덱싱하기 전에, Claude로 그 청크가 전체 문서에서 어떤 맥락인지 설명하는 50~100 토큰 분량의 짧은 문구를 만들어 청크 앞에 붙인다(Contextual Embeddings, Contextual BM25). 프롬프트 캐싱으로 이 전처리 비용을 100만 문서 토큰당 약 $1.02까지 낮췄다고 밝혔다.

앤트로픽이 여러 도메인에서 측정한 top-20 검색 실패율은 기본 5.7%에서, Contextual Embeddings만 적용하면 3.7%(35% 감소), Contextual BM25까지 더하면 2.9%(49% 감소), 여기에 상위 150개를 20개로 추리는 재순위(Cohere reranker)를 더하면 1.9%(67% 감소)까지 줄었다고 밝혔다. 즉 하이브리드 검색(벡터+BM25)과 재순위는 각자 따로도 유의미하지만, 청크 자체에 맥락을 채워 넣는 전처리가 먼저 있어야 효과가 더 커진다.

(참고: [Anthropic - Introducing Contextual Retrieval](https://www.anthropic.com/news/contextual-retrieval))

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

