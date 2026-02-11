[[JVM]]은 **Java 전용이 아니라 바이트코드(.class) 규격만 맞으면 어떤 언어든 실행할 수 있는 범용 실행 플랫폼**입니다.

## 왜 가능한가

JVM이 실행하는 것은 Java 소스코드가 아니라 **바이트코드**입니다. 어떤 언어든 자체 컴파일러가 JVM 바이트코드를 생성할 수 있으면 JVM 위에서 동작합니다.

```
Java     ─── javac ───┐
Kotlin   ─── kotlinc ──┤
Scala    ─── scalac ───┤──→  .class (바이트코드)  ──→  JVM  ──→  OS/CPU
Groovy   ─── groovyc ──┤
Clojure  ─── clojure ──┘
```

## 주요 JVM 언어

|언어|등장|특징|대표 사용처|
|---|---|---|---|
|**Kotlin**|2011|Java 완전 호환, 간결한 문법, Null 안전성|Android 공식, Spring 생태계|
|**Scala**|2004|함수형 + 객체지향 혼합, 강력한 타입 시스템|대규모 데이터 처리 (Spark, Akka)|
|**Groovy**|2003|동적 타이핑, 스크립트 지향|Gradle 빌드, Jenkins 파이프라인|
|**Clojure**|2007|Lisp 계열 함수형, 불변 데이터 중심|동시성 처리, 데이터 파이프라인|
|**JRuby**|2001|Ruby를 JVM 위에서 실행|Ruby 앱의 JVM 마이그레이션|
|**Jython**|1997|Python을 JVM 위에서 실행|Java-Python 통합|

## 실제 코드 비교 — 같은 바이트코드, 다른 문법

### Java

```java
public class Hello {
    public static void main(String[] args) {
        var list = List.of("A", "B", "C");
        list.stream()
            .filter(s -> s.equals("A"))
            .forEach(System.out::println);
    }
}
```

### Kotlin

```kotlin
fun main() {
    val list = listOf("A", "B", "C")
    list.filter { it == "A" }
        .forEach(::println)
}
```

### Scala

```scala
@main def hello(): Unit =
  val list = List("A", "B", "C")
  list.filter(_ == "A")
      .foreach(println)
```

세 코드 모두 컴파일하면 **동일한 JVM 바이트코드 규격**을 따르는 .class 파일이 생성되고, 같은 JVM 위에서 실행됩니다.

## JVM 언어의 장점

JVM 위에 올리면 해당 언어가 단독으로는 갖지 못하는 이점을 얻게 됩니다.

|장점|설명|
|---|---|
|**Java 생태계 활용**|수십만 개의 Java 라이브러리를 그대로 import 가능|
|**상호 운용**|Kotlin에서 Java 클래스 호출, 반대도 가능|
|**JVM 성능 혜택**|JIT 컴파일, GC, 멀티스레딩 최적화를 동일하게 누림|
|**플랫폼 독립성**|Write Once, Run Anywhere 그대로 적용|
|**성숙한 도구**|jconsole, jstack, VisualVM 등 모니터링 도구 공유|

## 상호 운용 예시 (Kotlin ↔ Java)

```kotlin
// Kotlin에서 Java 라이브러리 직접 사용
import java.util.HashMap

fun main() {
    val map = HashMap<String, Int>()   // Java 클래스를 Kotlin에서 사용
    map["score"] = 100
}
```

```java
// Java에서 Kotlin 클래스 직접 사용
public class Main {
    public static void main(String[] args) {
        MyKotlinClass obj = new MyKotlinClass();  // Kotlin 클래스를 Java에서 사용
        obj.greet();
    }
}
```

## GraalVM — JVM 언어를 넘어서

GraalVM은 JVM 기반이면서도 **비 JVM 언어까지 실행**할 수 있는 확장 런타임입니다.

```
┌────────────── GraalVM ──────────────┐
│                                      │
│  JVM 언어: Java, Kotlin, Scala       │
│  추가 지원: JavaScript, Python,      │
│            Ruby, R, LLVM(C/C++)     │
│                                      │
│  + AOT 컴파일 (native-image)        │
│    → JVM 없이 실행 가능한 바이너리    │
└──────────────────────────────────────┘
```

## 핵심 정리

JVM은 **바이트코드 실행 플랫폼**이지 Java 전용 머신이 아닙니다. Kotlin, Scala, Groovy 등 다양한 언어가 JVM 위에서 동작하며, Java의 방대한 라이브러리 생태계와 JIT·GC 같은 성능 최적화를 그대로 공유합니다. 특히 **Kotlin은 Android 공식 언어**로 채택되면서 현업에서 Java만큼 자주 접하는 JVM 언어가 되었습니다.