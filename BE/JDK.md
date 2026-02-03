Java 프로그램을 **개발·컴파일·디버깅·실행**하기 위한 모든 도구를 포함하는 종합 개발 키트입니다.

## 포함 관계

```
┌────────────────────── JDK ──────────────────────┐
│                                                   │
│  개발 도구                                        │
│  ┌─────────────────────────────────────────┐     │
│  │ javac   컴파일러                         │     │
│  │ java    실행기                           │     │
│  │ jdb     디버거                           │     │
│  │ jar     아카이브 도구                     │     │
│  │ javadoc 문서 생성기                       │     │
│  │ jlink   커스텀 런타임 생성                 │     │
│  │ jconsole / jvisualvm  모니터링            │     │
│  └─────────────────────────────────────────┘     │
│                                                   │
│  ┌──────────── JRE ────────────────┐             │
│  │                                  │             │
│  │  ┌──────── JVM ────────┐        │             │
│  │  │ Class Loader         │        │             │
│  │  │ Runtime Data Area    │        │             │
│  │  │ Execution Engine     │        │             │
│  │  └──────────────────────┘        │             │
│  │                                  │             │
│  │  표준 라이브러리 (java.lang 등)    │             │
│  └──────────────────────────────────┘             │
└───────────────────────────────────────────────────┘
```

## 주요 구성 도구

|도구|명령어|역할|
|---|---|---|
|**컴파일러**|`javac`|.java → .class 바이트코드 변환|
|**실행기**|`java`|JVM 위에서 바이트코드 실행|
|**디버거**|`jdb`|브레이크포인트, 변수 추적 등 디버깅|
|**아카이브**|`jar`|클래스·리소스를 .jar 파일로 패키징|
|**문서 생성**|`javadoc`|소스코드 주석 → HTML API 문서|
|**역어셈블러**|`javap`|.class 파일의 바이트코드 확인|
|**런타임 빌더**|`jlink`|필요한 모듈만 포함한 경량 런타임 생성|
|**모니터링**|`jconsole`|메모리, 스레드, GC 실시간 모니터링|
|**힙 덤프**|`jmap`|Heap 메모리 덤프 생성|
|**스레드 덤프**|`jstack`|실행 중인 스레드 상태 출력|
|**성능 분석**|`jstat`|GC, 클래스 로딩 통계 조회|

## 개발 흐름에서 JDK 도구 활용

```
 작성          컴파일         패키징          실행
─────        ──────        ──────        ──────
Hello.java → javac      → jar         → java
             (JDK)        (JDK)         (JRE)

 디버깅        문서화         모니터링
──────       ──────        ──────
 jdb          javadoc       jconsole
 (JDK)        (JDK)         (JDK)
```

```bash
# 실제 사용 예시
javac Hello.java              # 컴파일
java Hello                    # 실행
jar cf app.jar Hello.class    # 패키징
javap -c Hello.class          # 바이트코드 확인
javadoc -d docs Hello.java    # API 문서 생성
jstack <PID>                  # 운영 중 스레드 덤프
```

## 주요 JDK 배포판

|배포판|제공처|라이선스|특징|
|---|---|---|---|
|**Oracle JDK**|Oracle|상용 (유료 구독)|공식 지원, LTS 제공|
|**OpenJDK**|오픈소스 커뮤니티|GPL v2|Oracle JDK의 오픈소스 기반|
|**Adoptium (Temurin)**|Eclipse 재단|무료|가장 널리 사용되는 무료 배포판|
|**Amazon Corretto**|AWS|무료|AWS 환경 최적화|
|**Azul Zulu**|Azul Systems|무료/상용|다양한 플랫폼·아키텍처 지원|
|**GraalVM**|Oracle|무료/상용|AOT 컴파일, 다중 언어 지원|

## JDK 버전별 주요 변화

|버전|주요 기능|
|---|---|
|**JDK 8** (LTS)|Lambda, Stream API, Optional, PermGen → Metaspace|
|**JDK 11** (LTS)|독립 JRE 배포 중단, var, HttpClient, 모듈 시스템 안정화|
|**JDK 17** (LTS)|Sealed Classes, Pattern Matching, Records, ZGC 정식|
|**JDK 21** (LTS)|Virtual Threads, Record Patterns, Sequenced Collections|

## JVM vs JRE vs JDK 최종 비교

|항목|JVM|JRE|JDK|
|---|---|---|---|
|바이트코드 실행|✓|✓|✓|
|표준 라이브러리|✗|✓|✓|
|컴파일 (javac)|✗|✗|✓|
|디버깅 (jdb)|✗|✗|✓|
|모니터링 (jconsole)|✗|✗|✓|
|패키징 (jar)|✗|✗|✓|
|대상|실행 엔진 자체|일반 사용자|개발자|

## 핵심 정리

JDK는 **JRE(JVM + 라이브러리) + 개발 도구(javac, jdb, jar 등)**를 모두 포함하는 패키지입니다. Java 11 이후 독립 JRE가 사라지면서 개발자든 운영 환경이든 **JDK를 설치하는 것이 사실상 표준**이 되었고, 필요 시 jlink로 경량 런타임을 추출해 배포합니다.
