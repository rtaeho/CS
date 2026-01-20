**Java Virtual Machine**, 자바 프로그램을 실행하는 가상 컴퓨터입니다.

## 왜 필요한가

```
일반 프로그램:    소스코드 → 컴파일 → Windows용 실행파일
                                   → Mac용 실행파일
                                   → Linux용 실행파일
                          (OS마다 따로 컴파일 필요)

Java:           소스코드 → 컴파일 → .class (바이트코드)
                                       ↓
                              JVM이 각 OS에서 실행
                          (한 번 컴파일, 어디서든 실행)
```

---

## 구조

```
Java 소스코드 (.java)
        ↓ 컴파일
바이트코드 (.class)
        ↓
      JVM
   ┌───┴───┐
   ↓       ↓
Windows   Mac   Linux
 JVM      JVM    JVM
```

**"Write Once, Run Anywhere"** — 자바의 슬로건입니다.

---

## JVM의 역할

|역할|설명|
|---|---|
|바이트코드 실행|.class 파일을 해석하고 실행|
|메모리 관리|힙, 스택 등 메모리 영역 관리|
|가비지 컬렉션|안 쓰는 객체 자동 정리|
|JIT 컴파일|자주 쓰는 코드를 기계어로 최적화|

---

## 바이트코드란

```java
// Main.java
public class Main {
    public static void main(String[] args) {
        int a = 1 + 2;
    }
}
```

```
// 컴파일 후 바이트코드 (javap로 확인)
iconst_1    // 1을 스택에
iconst_2    // 2를 스택에
iadd        // 더하기
istore_1    // 결과 저장
```

기계어도 아니고 소스코드도 아닌 **중간 언어**입니다. JVM이 이걸 읽고 실행합니다.