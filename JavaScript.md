**웹 페이지에 동작을 추가하는 프로그래밍 언어**입니다.

---

## 예시

```javascript
// 변수
const name = "철수";

// 함수
function greet() {
    console.log("안녕");
}

// DOM 조작
document.querySelector("button").onclick = () => {
    alert("클릭됨!");
};
```

---

## 원래 용도: 브라우저

```html
<button id="btn">클릭</button>

<script>
    document.getElementById("btn").onclick = () => {
        alert("안녕!");
    };
</script>
```

HTML은 정적입니다. JavaScript가 있어야 **클릭, 입력, 애니메이션** 등이 가능합니다.

---

## 지금은 어디서든

|환경|용도|
|---|---|
|브라우저|웹 페이지 동작|
|Node.js|서버 개발|
|React Native|모바일 앱|
|Electron|데스크톱 앱|

---

## Java와 다름

```
Java ≠ JavaScript
```

이름만 비슷하고 완전히 다른 언어입니다. 마케팅 때문에 이름을 빌려왔을 뿐입니다.