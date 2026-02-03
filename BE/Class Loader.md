.class 파일(바이트코드)을 JVM 메모리에 동적으로 로드·링크·초기화하는 JVM의 서브시스템입니다.

## 동작 3단계

```
.class 파일 → [ Loading ] → [ Linking ] → [ Initialization ] → 사용 가능
```

### 1단계: Loading (로딩)

.class 파일을 읽어 바이너리 데이터를 Method Area에 저장하고, Heap에 해당 클래스의 `Class<?>` 객체를 생성합니다.

로딩은 **세 가지 계층의 클래스 로더**가 담당합니다.

|클래스 로더|로딩 대상|예시|
|---|---|---|
|**Bootstrap**|JVM 핵심 클래스|`java.lang.*`, `java.util.*`|
|**Extension (Platform)**|확장 라이브러리|`javax.*`, `jdk.*`|
|**Application (System)**|사용자 애플리케이션|classpath에 있는 클래스|

### 2단계: Linking (링크)

| 하위 단계       | 설명                                        |
| ----------- | ----------------------------------------- |
| **Verify**  | 바이트코드가 JVM 스펙에 맞는지 검증 (보안 핵심)             |
| **Prepare** | static 변수에 메모리 할당 후 **기본값**(0, null 등) 설정 |
| **Resolve** | 심볼릭 참조를 실제 메모리 주소(직접 참조)로 변환              |

### 3단계: Initialization (초기화)

static 변수에 **코드에 명시된 값**을 대입하고 `static { }` 블록을 실행합니다.

```java
class Example {
    static int count = 10;   // Prepare: 0 → Initialization: 10
    static {
        System.out.println("초기화 완료");
    }
}
```

## 위임 모델 (Delegation Model)

클래스 로더의 핵심 원칙은 **부모 위임 모델(Parent Delegation Model)** 입니다.

```
요청: "String 클래스 로드해줘"

Application ClassLoader
  │  "나는 모른다, 부모에게 위임"
  ▼
Extension ClassLoader
  │  "나도 모른다, 부모에게 위임"
  ▼
Bootstrap ClassLoader
  └─ "내가 로드할게!" ← java.lang.String 로드 완료
```

동작 순서는 다음과 같습니다. 클래스 로드 요청이 들어오면 먼저 **부모 로더에게 위임**하고, 부모가 찾지 못하면 자기 자신이 탐색합니다. 최상위(Bootstrap)까지 올라가도 못 찾으면 `ClassNotFoundException`이 발생합니다.

## 왜 부모 위임을 사용하는가?

```java
// 악의적인 사용자가 직접 만든 클래스
package java.lang;
public class String {
    // 악성 코드 ...
}
```

부모 위임이 없다면 이 가짜 `String`이 로드될 수 있습니다. 부모 위임 모델 덕분에 `java.lang.String`은 항상 Bootstrap 로더가 먼저 로드하므로, 핵심 클래스의 **위변조를 방지**할 수 있습니다.

## 부모 위임을 깨는 사례

|사례|이유|
|---|---|
|**JDBC (SPI)**|Bootstrap이 로드한 인터페이스가 Application 레벨 드라이버 구현체를 찾아야 함 → `Thread.currentThread().getContextClassLoader()` 사용|
|**톰캣 (WAS)**|여러 웹앱이 동일 클래스를 서로 다른 버전으로 사용 → 앱별 독립 클래스 로더|
|**OSGi**|모듈 간 클래스 격리·공유를 세밀하게 제어 → 네트워크형 위임|

## 핵심 정리

클래스 로더는 **로딩 → 링크 → 초기화** 세 단계로 클래스를 메모리에 적재하며, **부모 위임 모델**을 통해 중복 로딩을 방지하고 핵심 클래스의 무결성을 보장합니다. 이 구조 덕분에 JVM은 런타임에 필요한 클래스만 동적으로 불러오는 **지연 로딩(Lazy Loading)** 이 가능합니다.