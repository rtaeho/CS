JVM이 프로그램 실행 중 사용하는 메모리 공간을 용도별로 나눈 영역입니다.

## 전체 구조

```
┌───────────────── Runtime Data Area ─────────────────┐
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │          Method Area (= Metaspace)            │   │
│  │          모든 스레드 공유                       │   │
│  ├──────────────────────────────────────────────┤   │
│  │          Heap                                 │   │
│  │          모든 스레드 공유                       │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│  ┌─── 스레드 A ───┐  ┌─── 스레드 B ───┐  ...       │
│  │  JVM Stack     │  │  JVM Stack     │             │
│  │  PC Register   │  │  PC Register   │             │
│  │  Native Stack  │  │  Native Stack  │             │
│  └────────────────┘  └────────────────┘             │
└──────────────────────────────────────────────────────┘
```

## 공유 영역 (모든 스레드가 함께 사용)

### 1. Method Area (메서드 영역)

클래스 수준의 정보를 저장하며, JVM 시작 시 생성되고 종료 시 해제됩니다.

|저장 내용|예시|
|---|---|
|클래스 메타정보|클래스명, 부모 클래스, 인터페이스 목록|
|필드·메서드 정보|이름, 타입, 접근 제어자|
|static 변수|`static int count = 0;`|
|Runtime Constant Pool|리터럴 상수, 심볼릭 참조|

> **Java 8 이전**에는 Heap 내부의 **PermGen** 영역이 이 역할을 했지만, 크기 제한으로 `OutOfMemoryError: PermGen space`가 빈번했습니다. **Java 8부터**는 네이티브 메모리를 사용하는 **Metaspace**로 대체되어 기본적으로 OS 가용 메모리만큼 자동 확장됩니다.

### 2. Heap (힙)

`new` 키워드로 생성되는 **모든 객체와 배열**이 저장되며, **GC의 주요 대상**입니다.

```
┌──────────────────── Heap ────────────────────┐
│                                               │
│  ┌─ Young Generation ─┐   ┌─ Old Generation ─┐│
│  │ Eden │ S0 │ S1     │   │                  ││
│  └─────────────────────┘   └──────────────────┘│
└───────────────────────────────────────────────┘
```

|영역|설명|
|---|---|
|**Eden**|새 객체가 최초 할당되는 공간|
|**Survivor (S0, S1)**|Minor GC에서 살아남은 객체가 이동|
|**Old Generation**|오래 살아남은 객체가 승격(Promotion)되는 공간|

```java
// 이 두 객체 모두 Heap에 저장
String name = new String("hello");   // Heap → Eden
int[] arr  = new int[100];           // Heap → Eden
```

## 스레드별 영역 (스레드마다 독립 생성)

### 3. JVM Stack (자바 가상 머신 스택)

메서드 호출마다 **스택 프레임(Stack Frame)** 이 하나씩 push되고, 메서드가 종료되면 pop됩니다.

```
┌─── Stack Frame ───┐
│  Local Variables   │  ← 지역 변수, this, 매개변수
│  Operand Stack     │  ← 연산 중간 값
│  Frame Data        │  ← Constant Pool 참조, 예외 테이블
└────────────────────┘
```

```java
void foo() {
    int x = 1;      // foo 프레임의 Local Variables에 저장
    bar(x);          // bar 프레임이 push
}
void bar(int a) {
    int y = a + 2;   // bar 프레임의 Local Variables에 저장
}                    // bar 프레임 pop
```

### 4. PC Register (프로그램 카운터)

현재 스레드가 **실행 중인 바이트코드 명령어의 주소**를 저장합니다. 스레드 스케줄링 후 복귀 시 이 값을 참조해 이전 실행 위치를 이어갑니다. 네이티브 메서드 실행 중에는 `undefined` 상태입니다.

### 5. Native Method Stack

`native` 키워드가 붙은 **JNI(Java Native Interface) 메서드**를 위한 별도 스택입니다. C/C++ 등 네이티브 코드가 이 영역에서 실행됩니다.

## 영역별 비교 요약

|영역|공유 범위|생명주기|주요 에러|
|---|---|---|---|
|**Method Area**|전체 스레드|JVM 시작 ~ 종료|`OutOfMemoryError: Metaspace`|
|**Heap**|전체 스레드|GC가 관리|`OutOfMemoryError: Java heap space`|
|**JVM Stack**|스레드별|스레드 시작 ~ 종료|`StackOverflowError`|
|**PC Register**|스레드별|스레드 시작 ~ 종료|에러 없음|
|**Native Method Stack**|스레드별|스레드 시작 ~ 종료|`StackOverflowError`|

## 실행 예시로 보는 메모리 배치

```java
public class Main {
    static int total = 0;              // Method Area

    public static void main(String[] args) {
        Person p = new Person("Kim");  // p → Stack, 객체 → Heap
        total = p.getId();             // total → Method Area 갱신
    }
}
```

```
Method Area : Main 클래스 메타정보, static int total
Heap        : Person 객체 {"name": "Kim"}
JVM Stack   : main() 프레임 → 지역 변수 p (Heap 객체를 가리키는 참조)
PC Register : 현재 실행 중인 바이트코드 주소
```

## 핵심 정리

Runtime Data Area는 **공유 영역**(Method Area, Heap)과 **스레드별 영역**(JVM Stack, PC Register, Native Method Stack)으로 나뉩니다. 면접에서 가장 자주 나오는 포인트는 Heap의 **세대별 GC 구조**, Stack과 Heap의 **저장 대상 차이**, 그리고 Java 8 이후 **PermGen → Metaspace 전환**입니다.