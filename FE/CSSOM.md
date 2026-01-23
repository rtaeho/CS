**CSS를 브라우저가 트리 구조로 변환한 것**입니다.

DOM의 CSS 버전입니다.

---

### CSS → CSSOM 변환

```css
body {
  font-size: 16px;
}

div {
  color: blue;
}

p {
  color: red;
}
```

```
        [body]
         │ font-size: 16px
         │
       [div]
         │ color: blue
         │
        [p]
         │ color: red
```

---

### DOM + CSSOM = 렌더 트리

```
[DOM 트리]     +     [CSSOM]     =     [렌더 트리]
 (구조)              (스타일)           (실제 화면)
```

```
브라우저 렌더링 과정:

HTML ──▶ DOM 트리 ──┐
                    ├──▶ 렌더 트리 ──▶ 화면 출력
CSS ───▶ CSSOM ────┘
```

---

### 비교

|구분|DOM|CSSOM|
|---|---|---|
|대상|HTML|CSS|
|역할|문서 구조|스타일 정보|
|조합 결과|렌더 트리||
