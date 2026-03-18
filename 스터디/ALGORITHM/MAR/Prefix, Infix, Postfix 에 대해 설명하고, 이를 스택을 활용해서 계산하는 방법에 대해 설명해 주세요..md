수식에서 연산자의 위치에 따라 구분되는 세 가지 표기법으로, 컴파일러와 계산기가 수식을 처리하는 방식입니다.

## 세 가지 표기법

```
수식: 3 + 4 * 2

Infix  (중위):  3 + 4 * 2   ← 사람이 읽는 방식
Prefix (전위):  + 3 * 4 2   ← 연산자가 앞
Postfix(후위):  3 4 2 * +   ← 연산자가 뒤
```

|표기법|연산자 위치|괄호 필요 여부|주 사용처|
|---|---|---|---|
|Infix|피연산자 사이|필요|사람이 쓰는 수식|
|Prefix|피연산자 앞|불필요|LISP 계열 언어|
|Postfix|피연산자 뒤|불필요|컴파일러, 계산기|

---

## 1. Postfix 계산 (스택 활용)

숫자는 push, 연산자를 만나면 스택에서 2개 pop해 계산 후 push합니다.

```
수식: 3 4 2 * +

step 1: 3 → push(3)       [3]
step 2: 4 → push(4)       [3, 4]
step 3: 2 → push(2)       [3, 4, 2]
step 4: * → pop(2), pop(4) → 4*2=8 → push(8)  [3, 8]
step 5: + → pop(8), pop(3) → 3+8=11 → push(11) [11]

결과: 11 ✓
```

```java
int evalPostfix(String[] tokens) {
    Deque<Integer> stack = new ArrayDeque<>();

    for (String token : tokens) {
        if (token.matches("-?\\d+")) {          // 숫자면 push
            stack.push(Integer.parseInt(token));
        } else {                                // 연산자면 계산
            int b = stack.pop();
            int a = stack.pop();
            switch (token) {
                case "+" -> stack.push(a + b);
                case "-" -> stack.push(a - b);
                case "*" -> stack.push(a * b);
                case "/" -> stack.push(a / b);
            }
        }
    }
    return stack.pop();
}
```

---

## 2. Infix → Postfix 변환 (스택 활용)

연산자 우선순위를 고려해 스택에 연산자를 저장하고 적절한 시점에 꺼냅니다.

### 연산자 우선순위

```
* /  → 우선순위 2 (높음)
+ -  → 우선순위 1 (낮음)
(    → 우선순위 0
```

```
수식: 3 + 4 * 2

step 1: 3 → output: [3]            stack: []
step 2: + → stack: [+]             output: [3]
step 3: 4 → output: [3, 4]         stack: [+]
step 4: * → 우선순위 * > + 이므로 push
            stack: [+, *]          output: [3, 4]
step 5: 2 → output: [3, 4, 2]      stack: [+, *]
step 6: 끝 → stack 전부 pop
            output: [3, 4, 2, *, +]

결과: 3 4 2 * +  ✓
```

```java
String[] infixToPostfix(String[] tokens) {
    Deque<String> stack = new ArrayDeque<>();
    List<String> output = new ArrayList<>();

    Map<String, Integer> priority = Map.of("+", 1, "-", 1, "*", 2, "/", 2);

    for (String token : tokens) {
        if (token.matches("-?\\d+")) {          // 숫자
            output.add(token);
        } else if (token.equals("(")) {         // 여는 괄호
            stack.push(token);
        } else if (token.equals(")")) {         // 닫는 괄호
            while (!stack.peek().equals("("))
                output.add(stack.pop());
            stack.pop();                        // "(" 제거
        } else {                                // 연산자
            while (!stack.isEmpty()
                    && priority.getOrDefault(stack.peek(), 0)
                    >= priority.get(token))
                output.add(stack.pop());
            stack.push(token);
        }
    }
    while (!stack.isEmpty()) output.add(stack.pop());
    return output.toArray(new String[0]);
}
```

---

## 3. Prefix 계산 (스택 활용)

**오른쪽부터** 읽으며, 숫자는 push, 연산자를 만나면 2개 pop해 계산합니다.

```
수식: + 3 * 4 2  (오른쪽부터 읽기)

step 1: 2 → push(2)        [2]
step 2: 4 → push(4)        [2, 4]
step 3: * → pop(4),pop(2) → 4*2=8 → push(8)   [8]
step 4: 3 → push(3)        [8, 3]
step 5: + → pop(3),pop(8) → 3+8=11 → push(11) [11]

결과: 11 ✓
```

---

## 전체 흐름 정리

```
Infix: 3 + 4 * 2
       ↓ infixToPostfix()
Postfix: 3 4 2 * +
       ↓ evalPostfix()
결과: 11
```

> 컴파일러는 Infix로 작성된 코드를 내부적으로 **Postfix로 변환 후 계산**합니다. Postfix가 스택 기반 계산에 가장 적합한 표기법입니다.