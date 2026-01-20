**CSS(Cascading Style Sheets)** 는 **HTML의 스타일(디자인)을 담당하는 언어**입니다.

## 한마디로

HTML이 **뼈대**라면, CSS는 **옷과 화장**이에요.

## 예시

**HTML만 있을 때**

```html
<h1>안녕하세요</h1>
<p>반갑습니다</p>
```

→ 그냥 검은 글씨, 밋밋한 모습

**CSS 추가**

```css
h1 {
    color: blue;
    font-size: 32px;
}

p {
    color: gray;
    background-color: yellow;
    padding: 10px;
}
```

→ 색상, 크기, 배경 등 스타일 적용

## 역할 분리

|언어|역할|비유|
|---|---|---|
|HTML|구조/내용|뼈대, 골격|
|CSS|디자인/스타일|옷, 화장, 인테리어|
|JavaScript|동작/기능|행동, 움직임|

## CSS 적용 방법 3가지

```html
<!-- 1. 인라인 -->
<p style="color: red;">텍스트</p>

<!-- 2. 내부 스타일 -->
<style>
    p { color: red; }
</style>

<!-- 3. 외부 파일 (가장 권장) -->
<link rel="stylesheet" href="style.css">
```

## "Cascading"의 의미

CSS에서 **Cascading**은 "위에서 아래로 흐르는" 뜻이에요. 여러 스타일이 충돌하면 **우선순위**에 따라 적용됩니다.

```css
p { color: blue; }
p { color: red; }  /* 이게 적용됨 (나중에 선언) */
```

## 한줄 요약

CSS = **웹페이지를 예쁘게 꾸며주는 스타일 언어**