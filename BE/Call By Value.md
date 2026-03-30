함수 호출 시 인자의 **값 자체를 복사**하여 전달하는 방식으로, 함수 내부에서 값을 변경해도 원본에 영향을 주지 않습니다.

## Call By Value vs [[Call By Reference]]

||Call By Value|Call By Reference|
|---|---|---|
|**전달 방식**|값 복사|참조(주소) 전달|
|**원본 영향**|❌ 영향 없음|✅ 영향 있음|
|**메모리**|별도 공간 생성|같은 공간 공유|

## Java 예시 - 기본형 (Primitive Type)

```java
public static void change(int x) {
    x = 100; // 복사본만 변경
}

public static void main(String[] args) {
    int a = 10;
    change(a);
    System.out.println(a); // 10 → 원본 유지
}
```

## Java 예시 - 참조형 (Reference Type)

```java
public static void change(int[] arr) {
    arr[0] = 100; // 같은 객체를 참조하므로 원본 변경됨
}

public static void main(String[] args) {
    int[] arr = {1, 2, 3};
    change(arr);
    System.out.println(arr[0]); // 100 → 원본 변경됨
}
```

## ⚠️ Java는 항상 Call By Value

```
기본형 → 값 자체를 복사하여 전달
참조형 → 참조값(주소)을 복사하여 전달
         (주소를 복사한 것이므로 여전히 Call By Value)
```

```java
public static void reassign(int[] arr) {
    arr = new int[]{100, 200}; // 참조값(주소) 자체를 바꿔도
}

public static void main(String[] args) {
    int[] arr = {1, 2, 3};
    reassign(arr);
    System.out.println(arr[0]); // 1 → 원본 주소는 그대로
}
```

> Java는 참조형도 **참조값을 복사**하여 전달하므로 엄밀히 말하면 **항상 Call By Value**입니다. 참조형의 경우 같은 객체를 가리키기 때문에 내부 값 변경은 원본에 영향을 줄 수 있습니다.