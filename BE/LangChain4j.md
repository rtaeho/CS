**Java용 LLM 오케스트레이션 프레임워크**로, OpenAI·Anthropic·온프레미스 LLM과의 연동, 메모리, 툴 사용, RAG 파이프라인을 추상화해 제공합니다.

## 핵심 구성요소

- **ChatLanguageModel**: LLM과의 기본 대화 인터페이스
- **StreamingChatLanguageModel**: 토큰 단위 스트리밍 응답
- **AiServices**: 인터페이스 선언만으로 LLM 호출 자동 구현
- **ChatMemory**: 대화 히스토리 관리 (MessageWindowChatMemory 등)
- **Tools**: LLM이 호출할 수 있는 Java 메서드 정의
- **EmbeddingModel / EmbeddingStore**: RAG 파이프라인 구성

## 기본 사용

```java
// 의존성 (Gradle)
implementation 'dev.langchain4j:langchain4j-open-ai:0.35.0'

// ChatLanguageModel
ChatLanguageModel model = OpenAiChatModel.builder()
    .apiKey(System.getenv("OPENAI_API_KEY"))
    .modelName("gpt-4o")
    .build();

String response = model.generate("Java에서 Optional이란?");
```

## AiServices — 인터페이스 기반 추상화

```java
// 인터페이스 선언
interface Assistant {
    String chat(String userMessage);

    @SystemMessage("당신은 Java 전문가입니다.")
    String askJava(String question);
}

// 구현체 자동 생성
Assistant assistant = AiServices.builder(Assistant.class)
    .chatLanguageModel(model)
    .chatMemory(MessageWindowChatMemory.withMaxMessages(10))
    .build();

assistant.chat("스프링이란?");
```

## 스트리밍

```java
StreamingChatLanguageModel streamingModel = OpenAiStreamingChatModel.builder()
    .apiKey(System.getenv("OPENAI_API_KEY"))
    .modelName("gpt-4o")
    .build();

streamingModel.generate("WebFlux를 설명해줘", new StreamingResponseHandler<AiMessage>() {
    @Override
    public void onNext(String token) {
        System.out.print(token);       // 토큰 단위 수신
    }

    @Override
    public void onComplete(Response<AiMessage> response) {
        System.out.println("\n[완료]");
    }

    @Override
    public void onError(Throwable error) {
        error.printStackTrace();
    }
});
```

## Tools (함수 호출)

LLM이 판단해서 Java 메서드를 호출하도록 등록.

```java
class WeatherTools {
    @Tool("현재 도시의 날씨를 조회한다")
    String getWeather(@P("도시명") String city) {
        return weatherApi.fetch(city);   // 실제 API 호출
    }
}

Assistant assistant = AiServices.builder(Assistant.class)
    .chatLanguageModel(model)
    .tools(new WeatherTools())           // 툴 등록
    .build();

// LLM이 필요 시 자동으로 getWeather() 호출
assistant.chat("서울 날씨 알려줘");
```

## RAG 통합

```java
EmbeddingModel embeddingModel = new OpenAiEmbeddingModel(...);
EmbeddingStore<TextSegment> store = new ChromaEmbeddingStore(...);

// 문서 저장
EmbeddingStoreIngestor ingestor = EmbeddingStoreIngestor.builder()
    .embeddingModel(embeddingModel)
    .embeddingStore(store)
    .build();
ingestor.ingest(Document.from("Spring WebFlux는 ..."));

// RAG 적용 Assistant
ContentRetriever retriever = EmbeddingStoreContentRetriever.from(store);

Assistant assistant = AiServices.builder(Assistant.class)
    .chatLanguageModel(model)
    .contentRetriever(retriever)        // RAG 연결
    .build();
```

## 직접 API 호출 vs LangChain4j

| | 직접 API 호출 | LangChain4j |
|---|---|---|
| 유연성 | 높음 | 추상화로 일부 제한 |
| 메모리 관리 | 직접 구현 | 내장 제공 |
| 멀티 LLM 전환 | 코드 수정 필요 | 모델만 교체 |
| RAG 파이프라인 | 직접 구성 | 빌더로 조립 |
| 학습 비용 | 낮음 | 중간 |

## 핵심 정리

- LLM 연동·메모리·툴·RAG를 Java에서 추상화한 프레임워크 — Python의 LangChain과 동일한 역할

- `AiServices`로 인터페이스만 선언하면 구현 자동 생성 — 반복 코드 제거

- 멀티 LLM 지원(OpenAI, Anthropic, Ollama 등)으로 모델 교체가 쉬움

→ [[RAG]] | [[SSE]] | [[Spring WebFlux]]

