---
title: "try-with-resources"
tags: [Java, 자원관리, 예외처리]
status: published
---

try 블록이 끝날 때 선언한 자원의 `close()`를 자동으로 호출해 자원 누수를 막아주는 Java 7의 문법입니다.

## 사용 조건

- 자원 객체가 `AutoCloseable`(또는 그 하위 인터페이스인 `Closeable`)을 구현해야 합니다.
- 자원 변수를 `try()` 괄호 안에서 선언해야 합니다.

```java
try (BufferedReader br = new BufferedReader(new FileReader("path"))) {
    return br.readLine();
} catch (IOException e) {
    return null;
}
```

`InputStream`, `OutputStream`, `Connection`, `Statement`, `ResultSet` 등 JDK가 제공하는 대부분의 자원 클래스는 이미 `AutoCloseable`을 구현하고 있습니다.

## 왜 try-catch-finally 대신 쓰는가

기존 방식은 `finally`에서 `close()`를 직접 호출해야 합니다.

```java
BufferedReader br = null;
try {
    br = new BufferedReader(new FileReader("path"));
    return br.readLine();
} catch (IOException e) {
    return null;
} finally {
    if (br != null) {
        try {
            br.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

- `close()` 호출을 누락하면 커넥션·파일 디스크립터가 계속 점유되어 성능 문제와 메모리 누수로 이어집니다.
- `close()` 자체가 예외를 던질 수 있어 `finally` 안에 다시 try-catch를 중첩해야 합니다.
- 자원이 여러 개일 때, 먼저 닫은 자원에서 예외가 나면 뒤의 자원은 해제되지 않습니다.

try-with-resources는 이 문제를 문법 차원에서 해결합니다.

- try 블록을 벗어나는 순간(정상 종료·예외·return 모두) `close()`가 자동 호출됩니다.
- `finally` 없이도 자원이 정리되므로 코드가 짧아집니다.
- 여러 자원을 선언하면 **선언된 역순으로** 닫힙니다. 앞 자원의 `close()`가 실패해도 나머지는 모두 닫힙니다.

```java
// out이 먼저 닫히고, 그다음 in이 닫힌다
try (InputStream in = new FileInputStream("src");
     OutputStream out = new FileOutputStream("dst")) {
    in.transferTo(out);
}
```

## Suppressed Exception (억제된 예외)

try 블록의 예외와 `close()`의 예외가 동시에 발생하면, try 블록에서 발생한 **원래 예외(Primary Exception)** 가 전파되고 `close()`의 예외는 그 예외에 **억제된 예외**로 첨부됩니다.

```java
class CustomResource implements AutoCloseable {

    @Override
    public void close() throws Exception {
        throw new Exception("Close Exception 발생");
    }

    void process() throws Exception {
        throw new Exception("Primary Exception 발생");
    }
}
```

```
Exception in thread "main" java.lang.Exception: Primary Exception 발생
    at CustomResource.process(CustomResource.java:9)
    at Main.main(Main.java:5)
    Suppressed: java.lang.Exception: Close Exception 발생
        at CustomResource.close(CustomResource.java:5)
        at Main.main(Main.java:4)
```

반면 try-catch-finally에서는 `finally`의 `close()` 예외가 원래 예외를 **덮어써서** 진짜 원인이 스택 트레이스에서 사라집니다. `Throwable.addSuppressed()`로 직접 처리할 수도 있지만 코드가 복잡해지므로 try-with-resources에 맡기는 편이 낫습니다. 억제된 예외는 `Throwable.getSuppressed()`로 조회할 수 있습니다.

## 주의사항

- try 괄호 밖에서 이미 만들어진 변수는 대상이 되지 않습니다. Java 9부터는 `effectively final` 변수라면 `try (br)`처럼 참조만 넘길 수 있습니다.
- `close()`가 실제로 자원을 해제하는지는 구현에 달려 있습니다. [[커넥션 풀]]에서 얻은 `Connection`의 `close()`는 물리적 연결을 끊는 대신 풀로 반납합니다. 반납하지 않으면 풀이 고갈되어 이후 요청이 커넥션을 기다리다 타임아웃됩니다.
- `close()`가 던지는 예외가 Checked인지 Unchecked인지에 따라 처리 방식이 달라지므로 [[Exception]]의 예외 분류와 함께 보면 이해가 쉽습니다.
- 직접 만든 자원 클래스에서 `close()`를 구현할 때는 여러 번 호출돼도 안전하도록(멱등하게) 작성하는 것이 좋습니다.

## 핵심 정리

- `AutoCloseable` 구현체를 `try()` 안에서 선언하면 블록 종료 시 자동으로 `close()`가 호출됩니다.
- 여러 자원은 선언의 역순으로 닫히며, 하나가 실패해도 나머지는 모두 해제됩니다.
- `close()`에서 발생한 예외는 Suppressed Exception으로 남아 원래 예외를 가리지 않습니다.

→ [[try-with-resources에 대해 설명해 주세요]]
