함수 호출 시 인자의 **참조(주소)를 직접 전달**하는 방식으로, 함수 내부에서 값을 변경하면 원본에도 영향을 줍니다.

## 핵심 구조

```
[Call By Value]
원본: a = 10
복사본: x = 10  ← 복사본만 변경, 원본 유지

[Call By Reference]
원본: a = 10
참조: x → a    ← x를 변경하면 원본 a도 변경
```

## 주요 특징

|항목|내용|
|---|---|
|**전달 방식**|변수의 메모리 주소(참조) 전달|
|**원본 영향**|✅ 함수 내 변경이 원본에 반영|
|**메모리**|복사본 생성 없이 같은 공간 공유|

## C++ 예시 (Call By Reference 지원 언어)

```cpp
void change(int &x) {  // & → 참조 전달
    x = 100;
}

int main() {
    int a = 10;
    change(a);
    cout << a;  // 100 → 원본 변경됨
}
```

## ⚠️ Java는 Call By Reference가 없다

```java
// Java는 참조형도 참조값(주소)을 복사하여 전달
// → 엄밀히 Call By Reference가 아님

public static void reassign(int[] arr) {
    arr = new int[]{100, 200}; // 복사된 주소를 바꾼 것
}

public static void main(String[] args) {
    int[] arr = {1, 2, 3};
    reassign(arr);
    System.out.println(arr[0]); // 1 → 원본 주소는 그대로
}
```

## Call By Value vs Call By Reference

||Call By Value|Call By Reference|
|---|---|---|
|**전달**|값 복사|주소 직접 전달|
|**원본 영향**|❌|✅|
|**메모리**|별도 공간|공유|
|**지원 언어**|Java, Python 등|C++, C#(`ref`) 등|

> Java는 **Call By Reference처럼 보이는 경우**가 있지만, 실제로는 참조값을 복사한 **Call By Value**입니다. 진정한 Call By Reference는 C++의 `&` 참조자처럼 변수 자체를 공유하는 방식입니다.