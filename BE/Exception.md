---
title: "Exception"
tags: [Java, 예외처리, 에러]
status: published
---

프로그램 실행 중 발생하는 **예외 상황**입니다.

## 예시

```java
int result = 10 / 0;  // ArithmeticException: 0으로 나눌 수 없음

String str = null;
str.length();  // NullPointerException: null에 메서드 호출

int[] arr = new int[3];
arr[5] = 10;  // ArrayIndexOutOfBoundsException: 범위 초과
```

---

## 왜 필요한가

예외 처리가 없으면 **프로그램이 그냥 죽습니다.**

```java
// 예외 처리 없음
int result = 10 / 0;
System.out.println("여기 실행 안 됨");  // 프로그램 종료됨
```

```java
// 예외 처리 있음
try {
    int result = 10 / 0;
} catch (ArithmeticException e) {
    System.out.println("0으로 나눌 수 없습니다");
}
System.out.println("프로그램 계속 실행됨");  // 정상 실행
```

---

## Error vs Exception

||Error|Exception|
|---|---|---|
|원인|시스템 문제|프로그램 로직 문제|
|복구|불가능|가능|
|예시|OutOfMemoryError, StackOverflowError|NullPointerException, IOException|

Error는 메모리 부족 같은 심각한 문제라 처리해봤자 의미 없고, Exception은 개발자가 처리할 수 있는 예외 상황입니다.

## Checked vs Unchecked 예외

```
Throwable
├── Error           (시스템 수준 — 처리 불필요)
└── Exception
    ├── RuntimeException          ← Unchecked
    │    ├── NullPointerException
    │    ├── IllegalArgumentException
    │    ├── IndexOutOfBoundsException
    │    └── ClassCastException
    └── (그 외 Exception)         ← Checked
         ├── IOException
         ├── SQLException
         └── FileNotFoundException
```

| | Checked | Unchecked |
|---|---|---|
| 상속 | Exception (RuntimeException 제외) | RuntimeException |
| 컴파일 강제 | try-catch 또는 throws 선언 필수 | 선택 |
| 발생 원인 | 외부 환경 (파일, DB, 네트워크) | 프로그래밍 오류 (null, 잘못된 인덱스) |
| 예시 | IOException, SQLException | NullPointerException, IllegalArgumentException |

```java
// Checked — 컴파일러가 처리 강제
void readFile(String path) throws IOException {  // throws 선언 필수
    BufferedReader br = new BufferedReader(new FileReader(path));
}

// 또는 try-catch로 처리
void readFile(String path) {
    try {
        BufferedReader br = new BufferedReader(new FileReader(path));
    } catch (IOException e) {
        // 처리
    }
}

// Unchecked — 처리 선택
void divide(int a, int b) {
    if (b == 0) throw new IllegalArgumentException("0으로 나눌 수 없음");
    return a / b;
}
```

## try-with-resources (Java 7+)

AutoCloseable을 구현한 자원을 자동으로 닫아줌.

```java
// X 기존 방식 — finally에서 close() 직접 호출
BufferedReader br = null;
try {
    br = new BufferedReader(new FileReader("file.txt"));
    return br.readLine();
} finally {
    if (br != null) br.close();
}

// O try-with-resources
try (BufferedReader br = new BufferedReader(new FileReader("file.txt"))) {
    return br.readLine();
}  // 블록 종료 시 자동으로 br.close() 호출
```

## 커스텀 예외

```java
// Unchecked 커스텀 예외 (실무에서 더 선호)
public class PostNotFoundException extends RuntimeException {
    public PostNotFoundException(Long id) {
        super("Post not found: " + id);
    }
}

// 사용
throw new PostNotFoundException(id);
```

## 핵심 정리

- Checked: 컴파일러가 처리 강제, 외부 환경 문제 (IO, DB)

- Unchecked: RuntimeException 하위, 프로그래밍 오류 — 실무에서 커스텀 예외는 대부분 Unchecked 선호

- try-with-resources로 자원 누수 방지 — AutoCloseable 구현체에 사용