---
status: draft
---
# CS 학습 진행 현황

> `/cs` 인자 없이 호출하면 이 파일 기반으로 다음 학습 주제를 추천합니다.
> 학습 완료 시 `[ ]` → `[x]` 로 자동 변경됩니다.

last_category: Infa

---

## BE

- [X] @Async
- [X] @Autowired
- [X] @Bean
- [X] @Cacheable
- [X] @Component
- [X] @Configuration
- [X] @Controller
- [X] @Repository
- [X] @Service
- [X] @Transactional
- [X] AOT
- [X] CDC
- [X] Cache Aside
- [X] Cache Invalidation
- [X] Call By Reference
- [X] Call By Value
- [X] Class Loader
- [X] DI
- [X] EntityManager
- [X] Exception
- [X] Execution Engine
- [X] G1 GC
- [X] GC 동작 과정
- [X] GC 종류
- [X] GC
- [X] Hibernate
- [X] HikariCP
- [X] IoC
- [X] JDBC
- [X] JDK
- [X] JIT
- [X] JPA
- [X] JPQL
- [X] JRE
- [X] JVM
- [X] JWT
- [X] Lombok
- [X] N+1 문제
- [X] Native Query
- [X] Outbox 패턴
- [X] PER
- [X] Reachability
- [X] Reference Counting
- [X] Runtime Data Area
- [X] SOLID
- [X] STW
- [X] Spring AOP
- [X] Spring Container
- [X] Spring Proxy
- [X] TDD
- [X] Write Behind
- [X] Write Through
- [X] ZGC
- [X] record
- [X] 결합도
- [X] 깊은 복사
- [X] 단위 테스트
- [X] 동등성
- [X] 동일성
- [X] 런타임
- [X] 리플렉션
- [X] 방어적 복사
- [X] 보일러플레이트
- [X] 세션
- [X] 슬라이스 테스트
- [X] 얕은 복사
- [X] 어노테이션
- [X] 영속성 컨텍스트
- [X] 응집도
- [X] 인가
- [X] 인증
- [X] 인터페이스
- [X] 인터프리터
- [X] 일급 컬렉션
- [X] 지연 로딩
- [X] 직렬화
- [X] 추상 클래스
- [X] 캐시 스탬피드
- [X] 캡슐화
- [X] 컴파일
- [X] 통합 테스트
- [X] 함수형 프로그래밍
- [X] 힙 객체 참조 유형
- [X] Bean Validation (@Valid, @Validated)
- [ ] @ControllerAdvice / @ExceptionHandler
- [X] 접근 제어자
- [X] static
- [X] final
- [X] 다형성
- [X] 상속 vs 합성
- [X] 제네릭
- [X] equals와 hashCode
- [X] Enum
- [X] Optional
- [X] 불변 객체
- [X] Filter vs Interceptor
- [ ] @Scheduled
- [ ] @EventListener
- [X] 빈 스코프
- [ ] 빈 생명주기
- [ ] Spring Security 기초
- [ ] Spring Security 필터 체인
- [ ] OAuth2
- [X] Spring WebFlux / Reactor
- [X] SSE
- [X] Command 패턴
- [X] RAG
- [X] LangChain4j

---

## DB

- [X] ACID
- [X] Aggregation Pipeline
- [X] Binary log
- [X] Clustered Index
- [X] DB Replication
- [X] Elasticsearch
- [X] Hidden Clustered Index
- [X] InnoDB
- [X] LBCC
- [X] Liquibase
- [X] MVCC
- [X] MySQL
- [X] NoSQL
- [X] Non-Clustered Index
- [X] RDB
- [X] Redis
- [X] 격리 수준
- [X] 공유 락
- [X] 데드 락
- [X] 데이터베이스 활용 방식
- [X] 동시성(DB)
- [X] 무결성
- [X] 배타 락
- [X] 복합 인덱스
- [X] 인덱스
- [X] 인덱스가 안 타는 케이스
- [X] 정합성
- [X] 카디널리티
- [X] 커넥션 풀
- [X] 키 생성 전략
- [X] 트랜잭션
- [ ] 정규화
- [ ] 역정규화
- [ ] ERD
- [ ] 파티셔닝
- [ ] 샤딩
- [ ] 슬로우 쿼리
- [X] Vector DB

---

## FE

- [X] CSR
- [X] SSR
- [X] DOM
- [X] Virtual DOM
- [X] hydration
- [X] 렌더링
- [X] 이벤트 루프
- [X] 클로저
- [X] 호이스팅
- [X] 프로토타입(fe)
- [X] Promise
- [X] async
- [X] 비동기
- [X] useState
- [X] useRef
- [X] 메모이제이션
- [X] Redux
- [X] Zustand
- [X] Tanstack-Query
- [X] 타입스크립트
- [X] 번들러
- [X] 코드 스플리팅
- [X] 레이지 로딩
- [ ] useEffect
- [ ] useMemo / useCallback
- [ ] 웹 성능 최적화
- [ ] WebSocket
- [X] PWA
- [X] Vuex
- [X] AbortController

---

## Network

- [X] 3-Way Handshake
- [X] HTTP
- [X] HTTPS
- [X] TCP
- [X] UDP
- [X] DNS
- [X] REST
- [X] CORS
- [X] CSRF
- [X] OSI 7계층
- [X] TLS
- [X] SSL
- [X] NAT
- [X] URI / URL / URN
- [X] 공개키
- [X] 대칭키
- [X] 프록시
- [X] 리버스 프록시
- [X] 포워드 프록시
- [X] 멱등성
- [ ] HTTP/2
- [ ] HTTP/3
- [ ] WebSocket
- [X] gRPC
- [ ] Protocol Buffers
- [ ] OAuth

---

## OS

- [X] 프로세스
- [X] 스레드
- [X] Context Switch
- [X] CPU 스케줄링
- [X] deadlock
- [X] 뮤텍스 락
- [X] 동시성
- [X] 병렬성
- [X] 인터럽트
- [X] 시스템 콜
- [X] 커널
- [X] 페이지 폴트
- [ ] 가상 메모리
- [ ] 페이징
- [ ] 세그멘테이션
- [ ] 메모리 단편화
- [ ] 캐시 메모리

---

## Infa

- [X] CAP
- [X] CDN
- [X] WAS
- [X] 로드 밸런싱
- [X] 서킷 브레이커
- [X] 벌크헤드 패턴
- [X] 캐싱
- [X] 세션 클러스터링
- [X] scale-out / scale-up
- [X] 메시징 시스템 활용 방식
- [X] Docker
- [X] Kubernetes
- [X] CI/CD
- [X] Blue-Green 배포
- [X] Canary 배포
- [X] Grafana / Loki
- [X] GCS
- [X] XaaS (IaaS / PaaS / SaaS / BaaS / MBaaS / FaaS)
- [X] 모놀리식 vs MSA
- [X] Terraform
- [X] API Gateway
- [X] Service Mesh / Istio
- [X] Helm
- [X] 분산 추적
- [X] Rate Limiting

---

## 알고리즘

- [X] DP
- [X] 그래프
- [X] 그리디
- [X] 정렬
- [X] 커스텀 Comparator (문자열 연결 비교 패턴)
- [X] 탐색
- [X] 분할정복
- [X] 문자열
- [X] 수학
- [X] 백트래킹
- [ ] 위상 정렬
- [ ] 최단 경로 (다익스트라, 벨만포드)
- [ ] 최소 신장 트리 (크루스칼, 프림)
- [ ] 비트마스킹

---

## 자료구조

- [X] 배열
- [X] LinkedList
- [X] Stack
- [X] Queue
- [X] Deque
- [X] PriorityQueue
- [X] HashMap
- [X] Set
- [X] B-Tree
- [X] B+Tree
- [X] 해시 충돌
- [X] Heap
- [X] Red-Black Tree
- [ ] 트라이 (Trie)
- [ ] 세그먼트 트리
- [ ] 유니온 파인드
