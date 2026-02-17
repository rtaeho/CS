Grid는 **행(row)과 열(column)을 동시에 제어하여 2차원 레이아웃을 구성할 수 있는 CSS 레이아웃 모듈**입니다.

## Flexbox와의 차이

```
[Flexbox — 1차원: 한 방향만 제어]
→ →  → →
[1] [2] [3] [4]    ← 가로 또는 세로 중 하나만

[Grid — 2차원: 행과 열을 동시에 제어]
     열1    열2    열3
    ┌──────┬──────┬──────┐
행1 │  1   │  2   │  3   │  ← 가로와 세로를
    ├──────┼──────┼──────┤     동시에 제어
행2 │  4   │  5   │  6   │
    ├──────┼──────┼──────┤
행3 │  7   │  8   │  9   │
    └──────┴──────┴──────┘
```

## 핵심 용어

```
┌──────────────────────────────────────────┐
│              Grid Container               │
│                                          │
│  열1(Column)  열2       열3              │
│  ┌──────────┬──────────┬──────────┐     │
│  │          │          │          │ 행1  │
│  │ Grid Item│ Grid Item│ Grid Item│(Row) │
│  │          │          │          │     │
│  ├──────────┼──────────┼──────────┤     │
│  │          │          │          │ 행2  │
│  │ Grid Item│ Grid Item│ Grid Item│     │
│  │          │          │          │     │
│  └──────────┴──────────┴──────────┘     │
│                                          │
│  ──── Grid Line (격자선)                  │
│  ┼─── Grid Gap (간격)                    │
│  ████ Grid Cell (하나의 칸)               │
│  ████████ Grid Area (여러 셀의 영역)       │
└──────────────────────────────────────────┘
```

```
Grid Line 번호:

    1      2      3      4    ← 열 라인
    │      │      │      │
1 ──┌──────┬──────┬──────┐
    │  1   │  2   │  3   │
2 ──├──────┼──────┼──────┤
    │  4   │  5   │  6   │
3 ──└──────┴──────┴──────┘
↑ 행 라인

→ 라인 번호는 1부터 시작
→ 3열이면 라인은 1~4 (열 수 + 1)
```

## 기본 사용법

```html
<div class="grid-container">
    <div class="item">1</div>
    <div class="item">2</div>
    <div class="item">3</div>
    <div class="item">4</div>
    <div class="item">5</div>
    <div class="item">6</div>
</div>
```

```css
.grid-container {
    display: grid;
    grid-template-columns: 200px 200px 200px;  /* 3열, 각 200px */
    grid-template-rows: 100px 100px;            /* 2행, 각 100px */
    gap: 16px;
}
```

```
┌────200px────┬────200px────┬────200px────┐
│             │             │             │ 100px
│      1      │      2      │      3      │
│             │             │             │
├─────────────┼─────────────┼─────────────┤ ← 16px gap
│             │             │             │ 100px
│      4      │      5      │      6      │
│             │             │             │
└─────────────┴─────────────┴─────────────┘
```

## 컨테이너 속성 (부모)

### grid-template-columns / rows — 열과 행 정의

```css
/* 고정 크기 */
grid-template-columns: 200px 300px 200px;

/* fr (fraction) — 남은 공간 비율 분배 */
grid-template-columns: 1fr 2fr 1fr;

/* 혼합 */
grid-template-columns: 200px 1fr 1fr;

/* repeat() — 반복 */
grid-template-columns: repeat(3, 1fr);        /* 1fr 1fr 1fr */
grid-template-columns: repeat(4, 200px);       /* 200px 200px 200px 200px */

/* minmax() — 최소/최대 크기 */
grid-template-columns: repeat(3, minmax(200px, 1fr));

/* auto-fill / auto-fit — 반응형 */
grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
```

```
1fr 2fr 1fr (비율 1:2:1):
┌─────┬──────────┬─────┐
│ 25% │   50%    │ 25% │
└─────┴──────────┴─────┘

200px 1fr 1fr (고정 + 유연):
┌──200px──┬────────┬────────┐
│  고정    │ 나머지  │ 나머지  │
│         │ 균등    │ 균등    │
└─────────┴────────┴────────┘
```

### fr 단위 상세

```
fr = fraction (분수, 비율)
남은 공간을 비율로 나눔

컨테이너 너비: 1200px, gap: 없음

grid-template-columns: 1fr 1fr 1fr;
→ 1200px ÷ 3 = 400px씩
[  400px  ][  400px  ][  400px  ]

grid-template-columns: 1fr 2fr 1fr;
→ 1200px를 1:2:1로 = 300px, 600px, 300px
[  300px  ][    600px    ][  300px  ]

grid-template-columns: 200px 1fr 2fr;
→ 남은 공간: 1200 - 200 = 1000px를 1:2로
[ 200px ][ 333px  ][   667px   ]
```

### auto-fill vs auto-fit — 반응형 그리드

```css
/* auto-fill — 빈 트랙도 유지 */
grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));

/* auto-fit — 빈 트랙을 축소하여 아이템이 늘어남 */
grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
```

```
컨테이너 800px, 아이템 2개, 최소 200px

auto-fill:
[  아이템1  ][  아이템2  ][  빈 트랙  ][  빈 트랙  ]
→ 빈 공간을 트랙으로 유지

auto-fit:
[      아이템1      ][      아이템2      ]
→ 빈 트랙을 축소하여 아이템이 남은 공간 차지

→ 아이템 수가 충분하면 둘 다 동일하게 동작
→ 아이템이 적을 때 차이 발생
→ 실무에서는 auto-fit을 더 많이 사용
```

### gap — 간격

```css
.grid-container {
    gap: 16px;           /* 행/열 모두 16px */
    gap: 16px 24px;      /* 행 16px, 열 24px */
    row-gap: 16px;       /* 행 간격만 */
    column-gap: 24px;    /* 열 간격만 */
}
```

### grid-template-areas — 영역 이름으로 레이아웃

```css
.grid-container {
    display: grid;
    grid-template-columns: 200px 1fr 200px;
    grid-template-rows: 60px 1fr 80px;
    grid-template-areas:
        "header  header  header"
        "sidebar main   aside"
        "footer  footer  footer";
    gap: 16px;
    min-height: 100vh;
}

.header  { grid-area: header; }
.sidebar { grid-area: sidebar; }
.main    { grid-area: main; }
.aside   { grid-area: aside; }
.footer  { grid-area: footer; }
```

```
┌──────────────────────────────────────┐
│             header                    │  60px
├────────┬──────────────────┬──────────┤
│        │                  │          │
│sidebar │      main        │  aside   │  1fr
│ 200px  │                  │  200px   │
│        │                  │          │
├────────┴──────────────────┴──────────┤
│             footer                    │  80px
└──────────────────────────────────────┘
```

### justify-items / align-items — 셀 내부 정렬

```css
.grid-container {
    display: grid;
    justify-items: center;  /* 셀 내에서 가로 정렬 */
    align-items: center;    /* 셀 내에서 세로 정렬 */
    place-items: center;    /* 위 두 줄을 한 줄로 */
}
```

```
justify-items: start        justify-items: center       justify-items: end
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│[아이템]           │       │    [아이템]       │       │          [아이템]│
└──────────────────┘       └──────────────────┘       └──────────────────┘
```

### justify-content / align-content — 그리드 전체 정렬

```css
/* 그리드 자체가 컨테이너보다 작을 때 그리드의 위치를 조정 */
.grid-container {
    display: grid;
    justify-content: center;  /* 그리드 전체를 가로 가운데 */
    align-content: center;    /* 그리드 전체를 세로 가운데 */
}
```

## 아이템 속성 (자식)

### grid-column / grid-row — 셀 병합

```css
/* 라인 번호로 영역 지정 */
.item1 {
    grid-column: 1 / 3;  /* 열 라인 1부터 3까지 (2칸 차지) */
    grid-row: 1 / 2;     /* 행 라인 1부터 2까지 (1칸 차지) */
}

/* span으로 칸 수 지정 */
.item1 {
    grid-column: span 2;  /* 2열 차지 */
    grid-row: span 3;     /* 3행 차지 */
}
```

```
grid-column: 1 / 3 (2열 차지):

    1      2      3      4
    ├──────┼──────┼──────┤
1   │   item1     │  2   │
    │  (1/3)      │      │
    ├──────┼──────┼──────┤
2   │  3   │  4   │  5   │
    └──────┴──────┴──────┘


grid-column: 1 / 4, grid-row: 1 / 2 (전체 너비):

    ├──────────────────────┤
1   │       header          │
    ├──────┼──────┼────────┤
2   │      │      │        │
    └──────┴──────┴────────┘
```

### justify-self / align-self — 개별 아이템 정렬

```css
.item {
    justify-self: end;    /* 이 아이템만 셀 내에서 오른쪽 정렬 */
    align-self: center;   /* 이 아이템만 셀 내에서 세로 가운데 */
    place-self: center end; /* 한 줄로 */
}
```

## 실무에서 자주 사용하는 패턴

### 전체 페이지 레이아웃

```css
body {
    display: grid;
    grid-template-columns: 250px 1fr;
    grid-template-rows: 60px 1fr 80px;
    grid-template-areas:
        "header  header"
        "sidebar main"
        "footer  footer";
    min-height: 100vh;
}
```

```
┌──────────────────────────────┐
│           header              │
├─────────┬────────────────────┤
│         │                    │
│ sidebar │       main         │
│         │                    │
│         │                    │
├─────────┴────────────────────┤
│           footer              │
└──────────────────────────────┘
```

### 반응형 카드 그리드

```css
.card-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 24px;
}
```

```
넓은 화면 (1200px):
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
│ Card │ │ Card │ │ Card │ │ Card │
└──────┘ └──────┘ └──────┘ └──────┘

중간 화면 (800px):
┌────────┐ ┌────────┐ ┌────────┐
│  Card  │ │  Card  │ │  Card  │
└────────┘ └────────┘ └────────┘
┌────────┐
│  Card  │
└────────┘

좁은 화면 (400px):
┌──────────────┐
│     Card     │
├──────────────┤
│     Card     │
├──────────────┤
│     Card     │
├──────────────┤
│     Card     │
└──────────────┘

→ 미디어 쿼리 없이 자동 반응형 ✅
```

### 대시보드 레이아웃

```css
.dashboard {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    grid-template-rows: auto auto 1fr;
    gap: 16px;
}

.stat-card { }                              /* 1칸 */
.chart-large { grid-column: span 2; }       /* 2칸 */
.chart-full { grid-column: 1 / -1; }        /* 전체 너비 */
```

```
┌──────┬──────┬──────┬──────┐
│ Stat │ Stat │ Stat │ Stat │
├──────┴──────┼──────┴──────┤
│ Chart Large │ Chart Large │
├─────────────┴─────────────┤
│        Chart Full         │
└───────────────────────────┘
```

### 이미지 갤러리 (불규칙 그리드)

```css
.gallery {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    grid-auto-rows: 200px;
    gap: 8px;
}

.gallery .featured {
    grid-column: span 2;
    grid-row: span 2;
}
```

```
┌──────────────┬──────┐
│              │  2   │
│   1 (대형)   ├──────┤
│              │  3   │
├──────┬──────┼──────┤
│  4   │  5   │  6   │
└──────┴──────┴──────┘
```

## Flexbox vs Grid 선택 기준

|상황|Flexbox|Grid|
|---|---|---|
|**한 줄 배치**|✅|가능하지만 과도함|
|**네비게이션 바**|✅||
|**아이템 간 정렬**|✅||
|**전체 페이지 구조**||✅|
|**행과 열 동시 제어**||✅|
|**불규칙 그리드**||✅|
|**카드 그리드**|가능|✅ (더 간결)|
|**세로 가운데 정렬**|✅|✅|

```
[실무에서의 조합]

전체 페이지 → Grid
┌──────────────────────────────┐
│ Header → Flexbox             │
│ [Logo] [Nav] [Nav] [Login]   │
├─────────┬────────────────────┤
│ Sidebar │ Main               │
│ → Flex  │ Card Grid → Grid   │
│ [Menu]  │ ┌────┐┌────┐┌────┐│
│ [Menu]  │ │Card││Card││Card││
│ [Menu]  │ └────┘└────┘└────┘│
├─────────┴────────────────────┤
│ Footer → Flexbox             │
└──────────────────────────────┘

→ Grid와 Flexbox를 함께 사용하는 것이 일반적
→ 큰 구조는 Grid, 내부 정렬은 Flexbox
```

## 면접 포인트

- Grid는 **2차원 레이아웃 모듈**로, 행과 열을 동시에 제어할 수 있으며, Flexbox가 1차원(한 방향) 배치에 적합한 것과 대비됩니다. 실무에서는 둘을 함께 사용하여 큰 구조는 Grid, 내부 정렬은 Flexbox로 처리하는 것이 일반적입니다.
- `fr` 단위는 **남은 공간을 비율로 분배**하는 Grid 전용 단위이며, `repeat(auto-fit, minmax(250px, 1fr))`은 미디어 쿼리 없이 반응형 그리드를 구현하는 가장 대표적인 패턴입니다.
- `grid-template-areas`를 사용하면 **시각적으로 레이아웃을 정의**할 수 있어 코드 가독성이 높아지며, 전체 페이지 구조나 대시보드 레이아웃에서 특히 유용합니다.