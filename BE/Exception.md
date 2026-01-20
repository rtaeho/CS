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