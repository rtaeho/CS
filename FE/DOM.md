**DOM(Document Object Model)** 은 **HTML 문서를 JavaScript로 다룰 수 있게 객체로 바꿔놓은 것**입니다.

## 쉽게 말하면

브라우저가 HTML을 읽고, JavaScript가 조작할 수 있는 **트리 구조**로 변환한 것이에요.

## 예시

**HTML 코드**

```html
<html>
  <body>
    <div id="container">
      <p>안녕하세요</p>
    </div>
  </body>
</html>
```

**DOM 트리 (브라우저가 변환한 구조)**

```
html
 └── body
      └── div#container
           └── p
                └── "안녕하세요"
```

## 왜 필요한가?

HTML은 그냥 텍스트 파일이에요. JavaScript가 직접 텍스트를 조작하긴 어렵죠.

그래서 브라우저가 HTML을 **객체(Object)** 형태로 바꿔주면, JavaScript로 쉽게 접근하고 수정할 수 있습니다.

```javascript
// DOM을 통해 HTML 요소에 접근
const p = document.querySelector('p');

// 내용 변경
p.textContent = '반갑습니다';

// 스타일 변경
p.style.color = 'red';

// 새 요소 추가
const newDiv = document.createElement('div');
document.body.appendChild(newDiv);
```

## 일상 비유

|HTML|DOM|
|---|---|
|종이에 적힌 조직도|실제로 연락 가능한 조직 시스템|
|설계 도면|조작 가능한 3D 모델|

## 한줄 요약

DOM = **HTML을 JavaScript가 읽고 수정할 수 있게 만든 객체 트리 구조**