Flexbox는 **1차원(한 방향) 레이아웃을 효율적으로 배치, 정렬, 분배할 수 있는 CSS 레이아웃 모듈**입니다.

## 왜 필요한가

```css
/* Flexbox 이전 — 수직 가운데 정렬이 매우 어려웠음 */

/* ❌ 방법 1: position + transform */
.parent { position: relative; }
.child {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}

/* ❌ 방법 2: table-cell */
.parent {
    display: table-cell;
    vertical-align: middle;
    text-align: center;
}

/* ✅ Flexbox — 3줄로 해결 */
.parent {
    display: flex;
    justify-content: center;
    align-items: center;
}
```

## 핵심 개념 — 축(Axis)

```
[Flexbox는 두 개의 축을 기준으로 동작]

flex-direction: row (기본값)

주축 (Main Axis) →
┌──────────────────────────────────────┐
│  ┌──────┐  ┌──────┐  ┌──────┐      │  ↕ 교차축
│  │ 아이템1│  │ 아이템2│  │ 아이템3│      │    (Cross Axis)
│  └──────┘  └──────┘  └──────┘      │
└──────────────────────────────────────┘

flex-direction: column

          ↕ 주축 (Main Axis)
┌──────────────────┐
│  ┌──────────────┐│
│  │   아이템1     ││  → 교차축 (Cross Axis)
│  └──────────────┘│
│  ┌──────────────┐│
│  │   아이템2     ││
│  └──────────────┘│
│  ┌──────────────┐│
│  │   아이템3     ││
│  └──────────────┘│
└──────────────────┘

justify-content → 주축 방향 정렬
align-items     → 교차축 방향 정렬
```

## 기본 사용법

```html
<div class="container">
    <div class="item">1</div>
    <div class="item">2</div>
    <div class="item">3</div>
</div>
```

```css
.container {
    display: flex;  /* 자식 요소들이 Flex 아이템이 됨 */
}
```

```
[display: flex 적용 전]
┌──────────────────┐
│ 1                │
├──────────────────┤
│ 2                │
├──────────────────┤
│ 3                │
└──────────────────┘
→ div는 기본적으로 block → 세로로 쌓임

[display: flex 적용 후]
┌──────┬──────┬──────┐
│  1   │  2   │  3   │
└──────┴──────┴──────┘
→ 가로로 배치됨 (기본 flex-direction: row)
```

## 컨테이너 속성 (부모)

### flex-direction — 주축 방향

```css
.container { display: flex; flex-direction: row; }         /* 기본값 */
.container { display: flex; flex-direction: row-reverse; }
.container { display: flex; flex-direction: column; }
.container { display: flex; flex-direction: column-reverse; }
```

```
row:            [1] [2] [3] →
row-reverse:    ← [3] [2] [1]
column:         [1]
                [2]
                [3]
                ↓
column-reverse: [3]
                [2]
                [1]
                ↑
```

### justify-content — 주축 정렬

```css
.container {
    display: flex;
    justify-content: flex-start;    /* 기본값 */
}
```

```
flex-start:     [1][2][3]              ← 시작점에 몰림
flex-end:                  [1][2][3]   ← 끝점에 몰림
center:            [1][2][3]           ← 가운데
space-between:  [1]      [2]      [3]  ← 양끝 붙이고 균등 분배
space-around:    [1]    [2]    [3]     ← 각 아이템 양옆 동일 여백
space-evenly:   [1]   [2]   [3]       ← 모든 간격 동일
```

### align-items — 교차축 정렬

```css
.container {
    display: flex;
    height: 200px;
    align-items: center;
}
```

```
stretch (기본값):         flex-start:              center:
┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐
│┌────┐┌────┐┌────┐│   │┌────┐┌──┐┌─┐    │   │                  │
││ 1  ││ 2  ││ 3  ││   │└────┘└──┘└─┘    │   │┌────┐┌──┐┌─┐    │
││    ││    ││    ││   │                  │   │└────┘└──┘└─┘    │
│└────┘└────┘└────┘│   │                  │   │                  │
└──────────────────┘   └──────────────────┘   └──────────────────┘
→ 높이를 컨테이너에 맞춤   → 위에 붙음              → 세로 가운데

flex-end:                baseline:
┌──────────────────┐   ┌──────────────────┐
│                  │   │┌────┐            │
│                  │   ││ 1  │┌──┐        │
│┌────┐┌──┐┌─┐    │   │└────┘│2 │┌─┐     │  → 텍스트 기준선 정렬
│└────┘└──┘└─┘    │   │      └──┘└─┘     │
└──────────────────┘   └──────────────────┘
→ 아래에 붙음
```

### flex-wrap — 줄 바꿈

```css
.container {
    display: flex;
    flex-wrap: nowrap;  /* 기본값 — 한 줄에 억지로 넣음 */
    flex-wrap: wrap;    /* 넘치면 다음 줄로 */
}
```

```
nowrap (기본값):
┌──────────────────────────┐
│[1][2][3][4][5][6][7][8]  │  ← 한 줄에 다 넣음 (찌그러질 수 있음)
└──────────────────────────┘

wrap:
┌──────────────────────────┐
│[1]  [2]  [3]  [4]  [5]  │  ← 넘치면 줄 바꿈
│[6]  [7]  [8]             │
└──────────────────────────┘
```

### gap — 아이템 간 간격

```css
.container {
    display: flex;
    gap: 16px;          /* 모든 방향 16px */
    gap: 16px 24px;     /* 행 간격 16px, 열 간격 24px */
}
```

```
gap 없이:           gap: 16px:
[1][2][3]           [1]  [2]  [3]
                        16px 16px
```

## 아이템 속성 (자식)

### flex-grow — 남은 공간 차지 비율

```css
.item1 { flex-grow: 1; }
.item2 { flex-grow: 2; }
.item3 { flex-grow: 1; }
```

```
컨테이너 너비: 800px
아이템 기본 너비: 각 100px → 남은 공간: 500px

flex-grow: 0 (기본값):
[100px][100px][100px]                  (500px 남음)

flex-grow: 1, 2, 1 (비율 1:2:1):
남은 500px를 1:2:1로 분배
[100+125=225px][100+250=350px][100+125=225px]
```

### flex-shrink — 공간 부족 시 축소 비율

```css
.item1 { flex-shrink: 1; }  /* 기본값 — 축소됨 */
.item2 { flex-shrink: 0; }  /* 축소 안 됨 */
```

```
컨테이너: 300px, 아이템 각 200px (총 600px → 300px 초과)

flex-shrink: 1 (기본):
[100px][100px][100px]  ← 균등하게 축소

item2만 flex-shrink: 0:
[50px][200px][50px]    ← item2는 축소 안 됨, 나머지가 더 축소
```

### flex-basis — 기본 크기

```css
.item { flex-basis: 200px; }  /* width 대신 사용 */
.item { flex-basis: 30%; }
.item { flex-basis: auto; }   /* 기본값 — 콘텐츠 크기 */
```

```
flex-basis vs width:
→ flex-basis는 주축 방향의 기본 크기
→ flex-direction: row → 너비
→ flex-direction: column → 높이
→ flex-grow, flex-shrink에 의해 변경될 수 있음
```

### flex 단축 속성

```css
/* flex: flex-grow flex-shrink flex-basis */
.item { flex: 0 1 auto; }   /* 기본값 */
.item { flex: 1; }           /* flex: 1 1 0% — 균등 분배 */
.item { flex: none; }        /* flex: 0 0 auto — 크기 고정 */
.item { flex: 2; }           /* flex: 2 1 0% — 2배 비율 */
```

### align-self — 개별 아이템 교차축 정렬

```css
.container { display: flex; align-items: flex-start; }
.item2 { align-self: flex-end; }  /* 이 아이템만 다르게 정렬 */
```

```
┌──────────────────────────┐
│┌────┐          ┌────┐    │
│└────┘          └────┘    │
│                          │
│          ┌────┐          │  ← item2만 flex-end
│          └────┘          │
└──────────────────────────┘
```

### order — 배치 순서

```css
.item1 { order: 3; }
.item2 { order: 1; }
.item3 { order: 2; }
```

```
HTML 순서:  [1] [2] [3]
화면 표시:  [2] [3] [1]  ← order 값이 작은 순서대로

→ HTML 구조 변경 없이 시각적 순서만 변경 가능
```

## 실무에서 자주 사용하는 패턴

### 네비게이션 바

```css
.navbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 24px;
    height: 60px;
}
```

```
┌──────────────────────────────────────────┐
│ Logo          Home  Products  Cart  Login│
│ ←───→                        ←─────────→│
│ space-between으로 양쪽 끝에 배치          │
└──────────────────────────────────────────┘
```

### 카드 레이아웃

```css
.card-container {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
}
.card {
    flex: 1 1 300px;  /* 최소 300px, 남으면 균등 분배 */
}
```

```
넓은 화면:
┌──────┐ ┌──────┐ ┌──────┐
│ Card │ │ Card │ │ Card │
└──────┘ └──────┘ └──────┘

좁은 화면 (자동 줄 바꿈):
┌──────┐ ┌──────┐
│ Card │ │ Card │
└──────┘ └──────┘
┌──────┐
│ Card │
└──────┘
```

### 수직 수평 가운데 정렬

```css
.center {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
}
```

```
┌──────────────────────────┐
│                          │
│                          │
│        ┌────────┐        │
│        │ 콘텐츠  │        │
│        └────────┘        │
│                          │
│                          │
└──────────────────────────┘
```

### 푸터를 페이지 하단에 고정

```css
body {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}
main {
    flex: 1;  /* 남은 공간 모두 차지 */
}
footer {
    /* flex-grow 기본값 0 → 고정 크기 */
}
```

```
┌──────────────────┐
│ Header           │
├──────────────────┤
│                  │
│ Main (flex: 1)   │  ← 남은 공간 모두 차지
│                  │
├──────────────────┤
│ Footer           │  ← 항상 하단에 위치
└──────────────────┘
```

## Flexbox vs Grid

```
Flexbox: 1차원 레이아웃 (가로 또는 세로)
Grid:    2차원 레이아웃 (가로 + 세로 동시)
```

|항목|Flexbox|Grid|
|---|---|---|
|**차원**|1차원 (한 방향)|2차원 (행 + 열)|
|**적합한 경우**|한 줄 배치, 정렬|전체 페이지 레이아웃|
|**콘텐츠 기반**|콘텐츠 크기에 따라 유연|그리드 구조에 맞춤|
|**사용 예시**|네비게이션, 카드 행, 정렬|대시보드, 갤러리, 전체 레이아웃|

```
[Flexbox가 적합]
[Logo] [Menu1] [Menu2] [Menu3] [Login]  ← 한 줄 배치

[Grid가 적합]
┌────────┬────────┬────────┐
│ Header │ Header │ Header │  ← 행과 열을 동시에 제어
├────────┼────────┤        │
│ Sidebar│ Main   │  Aside │
│        │        │        │
├────────┴────────┴────────┤
│ Footer                   │
└──────────────────────────┘
```

## 면접 포인트

- Flexbox는 **1차원 레이아웃 모듈**로, 주축(Main Axis)과 교차축(Cross Axis) 두 축을 기반으로 아이템을 배치하고 정렬합니다. `justify-content`는 주축, `align-items`는 교차축 방향을 제어합니다.
- Flexbox와 Grid의 선택 기준은 **차원**이며, 한 방향(행 또는 열)의 배치는 Flexbox, 행과 열을 동시에 제어하는 전체 레이아웃은 Grid가 적합합니다. 실무에서는 둘을 함께 사용하는 것이 일반적입니다.
- `flex: 1`은 `flex-grow: 1, flex-shrink: 1, flex-basis: 0%`의 단축 속성으로, 남은 공간을 균등하게 분배하는 가장 흔한 패턴이며, 이 동작 원리를 이해하는 것이 중요합니다.