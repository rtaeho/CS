**HyperText Markup Language**, 웹 페이지의 구조를 정의하는 언어입니다.

---

## 예시

```html
<!DOCTYPE html>
<html>
  <head>
    <title>페이지 제목</title>
  </head>
  <body>
    <h1>안녕하세요</h1>
    <p>반갑습니다</p>
    <button>클릭</button>
  </body>
</html>
```

---

## 태그로 구조를 표현

```html
<h1>제목</h1>           <!-- 제목 -->
<p>문단입니다</p>        <!-- 문단 -->
<a href="...">링크</a>  <!-- 링크 -->
<img src="..." />       <!-- 이미지 -->
<ul>                    <!-- 목록 -->
  <li>항목1</li>
  <li>항목2</li>
</ul>
```

---

## HTML / CSS / JavaScript 역할

||역할|비유|
|---|---|---|
|HTML|구조|뼈대|
|CSS|스타일|옷, 화장|
|JavaScript|동작|근육, 행동|

```html
<button>클릭</button>                  <!-- HTML: 버튼 존재 -->
<style>button { color: red; }</style>  <!-- CSS: 빨간색 글씨 -->
<script>button.onclick = () => alert("hi")</script>  <!-- JS: 클릭 시 동작 -->
```

---

## 어원

- **HyperText**: 링크로 연결된 텍스트
- **Markup**: 태그로 의미를 표시
- **Language**: 언어