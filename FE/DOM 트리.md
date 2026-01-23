**HTML 문서를 브라우저가 트리 구조로 변환한 것**입니다.

---

### HTML → DOM 트리 변환

```html
<!DOCTYPE html>
<html>
  <head>
    <title>제목</title>
  </head>
  <body>
    <div>
      <p>안녕하세요</p>
    </div>
  </body>
</html>
```

```
         [document]
              │
           [html]
           ┌──┴──┐
       [head]   [body]
          │        │
       [title]   [div]
          │        │
       "제목"     [p]
                   │
               "안녕하세요"
```

---

### 왜 트리로 만들까?

|이유|설명|
|---|---|
|구조화|부모-자식 관계 명확|
|탐색|원하는 요소 찾기 쉬움|
|조작|JavaScript로 수정 가능|

---

### JavaScript로 DOM 조작

```javascript
// 요소 찾기
const p = document.querySelector('p');

// 내용 변경
p.textContent = '반갑습니다';

// 요소 추가
const newDiv = document.createElement('div');
document.body.appendChild(newDiv);
```
