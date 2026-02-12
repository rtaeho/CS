WCAG(Web Content Accessibility Guidelines)는 W3C에서 제정한 **웹 콘텐츠의 접근성을 보장하기 위한 국제 표준 지침**으로, 장애인을 포함한 모든 사용자가 웹을 이용할 수 있도록 구체적인 기준을 제시합니다.

## WCAG 버전 역사

| 버전           | 연도   | 특징                          |
| ------------ | ---- | --------------------------- |
| **WCAG 1.0** | 1999 | 최초 지침, HTML 중심              |
| **WCAG 2.0** | 2008 | 기술 독립적, 4대 원칙 수립 (현재 널리 사용) |
| **WCAG 2.1** | 2018 | 모바일, 저시력, 인지 장애 기준 추가       |
| **WCAG 2.2** | 2023 | 인지/학습 장애, 모바일 접근성 강화        |
| **WCAG 3.0** | 작업 중 | 완전히 새로운 구조, 더 넓은 범위 예정      |

## 4대 원칙 (POUR)

```
P - Perceivable  (인식의 용이성)  → 콘텐츠를 인식할 수 있는가?
O - Operable     (운용의 용이성)  → 기능을 조작할 수 있는가?
U - Understandable (이해의 용이성) → 내용을 이해할 수 있는가?
R - Robust       (견고성)        → 다양한 환경에서 동작하는가?
```

## 적합성 수준 (Level)

WCAG는 각 기준을 **세 단계의 적합성 수준**으로 분류합니다.

```
Level A   → 최소 수준 (반드시 준수)
Level AA  → 권장 수준 (대부분의 법률/정책이 요구하는 수준)
Level AAA → 최고 수준 (모든 콘텐츠에 적용하기는 어려움)
```

|수준|의미|예시|
|---|---|---|
|**A**|이것을 안 지키면 특정 사용자가 아예 이용 불가|이미지에 alt 텍스트 제공|
|**AA**|이것을 지키면 대부분의 사용자가 이용 가능|명도 대비 4.5:1 이상|
|**AAA**|가장 높은 수준의 접근성 보장|명도 대비 7:1 이상|

```
[실무에서의 목표]
대부분의 프로젝트: Level AA 준수 목표
법적 요구사항:     한국, 미국, EU 모두 AA 수준 요구
Level AAA:        특수한 경우에만 (의료, 공공 서비스 등)
```

## 원칙별 주요 기준

### 1. 인식의 용이성 (Perceivable)

|기준|수준|내용|구현 예시|
|---|---|---|---|
|**1.1.1** 대체 텍스트|A|텍스트가 아닌 콘텐츠에 대체 텍스트 제공|이미지에 alt 속성|
|**1.2.1** 자막 제공|A|녹화된 영상에 자막 제공|video에 track 요소|
|**1.3.1** 정보와 관계|A|구조적 정보를 프로그래밍적으로 결정 가능|시맨틱 HTML 사용|
|**1.4.3** 명도 대비|AA|텍스트와 배경의 대비율 4.5:1 이상|충분한 색상 대비|
|**1.4.6** 명도 대비 강화|AAA|대비율 7:1 이상|더 높은 대비|
|**1.4.4** 텍스트 크기 조절|AA|200%까지 확대해도 기능 손실 없음|상대 단위(rem) 사용|

```html
<!-- 1.1.1 대체 텍스트 (Level A) -->

<!-- ❌ -->
<img src="chart.png">

<!-- ✅ 의미 있는 이미지 -->
<img src="chart.png" alt="2024년 월별 매출 추이, 12월 최고 매출 기록">

<!-- ✅ 장식용 이미지 -->
<img src="divider.png" alt="">

<!-- ✅ 복잡한 이미지는 긴 설명 연결 -->
<img src="complex-chart.png"
     alt="분기별 매출 비교 차트"
     aria-describedby="chart-desc">
<p id="chart-desc" class="sr-only">
    1분기 1,200만원, 2분기 1,500만원, 3분기 1,800만원, 4분기 2,100만원으로
    지속적인 성장세를 보이고 있습니다.
</p>
```

```css
/* 1.4.3 명도 대비 (Level AA: 4.5:1 이상) */

/* ❌ 대비율 1.9:1 — Level A도 미달 */
.text-bad { color: #cccccc; background: #ffffff; }

/* ✅ 대비율 4.6:1 — Level AA 충족 */
.text-aa { color: #767676; background: #ffffff; }

/* ✅ 대비율 8.6:1 — Level AAA 충족 */
.text-aaa { color: #595959; background: #ffffff; }

/* 1.4.4 텍스트 크기 조절 (Level AA) */
/* ❌ 고정 단위 — 확대 불가 */
.text-fixed { font-size: 14px; }

/* ✅ 상대 단위 — 브라우저 설정에 따라 확대 */
.text-flexible { font-size: 0.875rem; }
```

### 2. 운용의 용이성 (Operable)

|기준|수준|내용|구현 예시|
|---|---|---|---|
|**2.1.1** 키보드 접근|A|모든 기능을 키보드로 사용 가능|button, a 태그 사용|
|**2.1.2** 키보드 트랩 방지|A|키보드 포커스가 갇히지 않음|모달에서 ESC로 탈출 가능|
|**2.4.1** 건너뛰기 링크|A|반복 콘텐츠 건너뛰기 가능|Skip Navigation 링크|
|**2.4.3** 포커스 순서|A|논리적 순서로 포커스 이동|DOM 순서와 시각 순서 일치|
|**2.4.7** 포커스 표시|AA|현재 포커스 위치가 시각적으로 보임|outline 스타일 유지|
|**2.5.8** 타겟 크기|AA|터치 타겟 최소 24x24px|버튼 크기 확보|

```html
<!-- 2.4.1 건너뛰기 링크 (Level A) -->
<body>
    <!-- 스크린 리더/키보드 사용자가 본문으로 바로 이동 -->
    <a href="#main-content" class="skip-link">본문으로 바로가기</a>

    <header>
        <nav>
            <!-- 수십 개의 메뉴 링크... -->
        </nav>
    </header>

    <main id="main-content">
        <!-- 본문 내용 -->
    </main>
</body>

<style>
/* 평소에는 숨기고 Tab으로 포커스 시 표시 */
.skip-link {
    position: absolute;
    top: -40px;
    left: 0;
    padding: 8px;
    background: #000;
    color: #fff;
    z-index: 100;
}
.skip-link:focus {
    top: 0;
}
</style>
```

```html
<!-- 2.1.1 키보드 접근 (Level A) -->

<!-- ❌ 키보드로 접근/실행 불가 -->
<div onclick="openMenu()">메뉴 열기</div>

<!-- ✅ 키보드로 Tab 이동 + Enter 실행 가능 -->
<button onclick="openMenu()">메뉴 열기</button>

<!-- 2.1.2 키보드 트랩 방지 (Level A) -->
<div role="dialog" aria-modal="true">
    <h2>알림</h2>
    <p>작업이 완료되었습니다.</p>
    <button onclick="closeModal()">확인</button>
    <!-- ESC 키로도 닫을 수 있어야 함 -->
</div>

<script>
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeModal();
});
</script>
```

### 3. 이해의 용이성 (Understandable)

|기준|수준|내용|구현 예시|
|---|---|---|---|
|**3.1.1** 페이지 언어|A|기본 언어 명시|html lang 속성|
|**3.2.1** 포커스 시 변경 없음|A|포커스만으로 맥락 변경 안 됨|자동 제출 금지|
|**3.3.1** 오류 식별|A|입력 오류를 텍스트로 안내|오류 메시지 제공|
|**3.3.2** 레이블/지시문|A|입력 필드에 레이블 제공|label 태그 연결|
|**3.3.3** 오류 수정 제안|AA|오류 수정 방법 제시|구체적 안내 메시지|

```html
<!-- 3.3.1 + 3.3.3 오류 안내 (Level A + AA) -->

<!-- ❌ 어디가 잘못인지 모름 -->
<p style="color: red;">입력이 잘못되었습니다</p>
<input type="email">

<!-- ✅ 구체적 오류 위치 + 수정 방법 안내 -->
<label for="email">이메일 주소 (필수)</label>
<input type="email"
       id="email"
       aria-invalid="true"
       aria-describedby="email-error"
       aria-required="true">
<p id="email-error" role="alert" style="color: #d32f2f;">
    ⚠️ 이메일 형식이 올바르지 않습니다. 예: hong@example.com
</p>
```

### 4. 견고성 (Robust)

|기준|수준|내용|구현 예시|
|---|---|---|---|
|**4.1.1** 파싱|A (2.0)|유효한 HTML 마크업|W3C Validator 통과|
|**4.1.2** 이름, 역할, 값|A|UI 컴포넌트의 역할과 상태 전달|ARIA 속성 사용|

```html
<!-- 4.1.2 이름, 역할, 값 (Level A) -->

<!-- ❌ 스크린 리더가 역할을 알 수 없음 -->
<div class="accordion-header" onclick="toggle()">
    자주 묻는 질문
</div>
<div class="accordion-body">...</div>

<!-- ✅ 역할과 상태를 명확히 전달 -->
<button aria-expanded="false"
        aria-controls="faq-panel"
        onclick="toggleAccordion(this)">
    자주 묻는 질문
</button>
<div id="faq-panel"
     role="region"
     hidden>
    질문과 답변 내용...
</div>

<script>
function toggleAccordion(button) {
    const panel = document.getElementById('faq-panel');
    const isExpanded = button.getAttribute('aria-expanded') === 'true';

    button.setAttribute('aria-expanded', !isExpanded);
    panel.hidden = isExpanded;
}
</script>
```

## WCAG 적합성 수준 비교 요약

```
[Level A — 최소 기준]
✅ 이미지에 alt 텍스트
✅ 키보드로 모든 기능 사용 가능
✅ 페이지 언어 명시
✅ 입력 오류 텍스트로 안내

[Level AA — 권장 기준 (법적 요구)]
✅ Level A 전체 +
✅ 명도 대비 4.5:1 이상
✅ 텍스트 200% 확대 가능
✅ 포커스 시각적 표시
✅ 오류 수정 방법 제시

[Level AAA — 최고 수준]
✅ Level A + AA 전체 +
✅ 명도 대비 7:1 이상
✅ 수어 통역 제공
✅ 전문 용어 설명 제공
```

## 국가별 법적 요구사항

|국가|법률|요구 수준|
|---|---|---|
|**한국**|장애인차별금지법 + KWCAG|AA 수준|
|**미국**|ADA + Section 508|WCAG 2.0 AA|
|**EU**|European Accessibility Act|WCAG 2.1 AA|

## WCAG 검사 도구

```
[자동 검사]
Chrome Lighthouse:  F12 → Lighthouse 탭 → Accessibility 점수
axe DevTools:       Chrome 확장, 위반 사항 상세 안내
WAVE:               https://wave.webaim.org

[수동 검사]
키보드 테스트:       Tab, Shift+Tab, Enter, ESC로 전체 탐색
스크린 리더 테스트:   VoiceOver(Mac), NVDA(Windows)
명도 대비 검사:      https://webaim.org/resources/contrastchecker
```

## 면접 포인트

- WCAG의 핵심은 **4대 원칙(POUR)**과 **3단계 적합성 수준(A/AA/AAA)**이며, 실무에서는 **Level AA**를 목표로 합니다.
- 한국을 포함한 대부분의 국가에서 **법적으로 AA 수준을 요구**하고 있으며, 미준수 시 차별 행위로 판단되어 법적 제재를 받을 수 있습니다.
- 개발자 관점에서 가장 중요한 것은 **시맨틱 HTML을 기본으로 사용하고, 키보드 접근성을 보장하며, 대체 텍스트와 명도 대비를 지키는 것**이며, 이것만으로도 대부분의 A/AA 기준을 충족할 수 있습니다.