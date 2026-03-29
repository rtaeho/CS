JavaScript 파일 안에서 CSS 스타일을 작성하는 방식으로, 컴포넌트 단위로 스타일을 관리할 수 있게 해주는 기술입니다.

## 기존 CSS와의 차이

||기존 CSS|CSS-in-JS|
|---|---|---|
|**작성 위치**|`.css` 파일|`.js` / `.ts` 파일 내부|
|**스코프**|전역|컴포넌트 단위|
|**동적 스타일**|클래스 교체 방식|JS 변수 직접 사용|
|**클래스명 충돌**|발생 가능|자동 해시 처리로 방지|

## 동작 방식

```
컴포넌트에 스타일 작성
→ 런타임에 고유 클래스명 생성 (ex. .sc-abc123)
→ <style> 태그로 주입
→ 해당 클래스명을 컴포넌트에 적용
```

## 대표 예시 (styled-components)

```jsx
import styled from 'styled-components';

const Button = styled.button`
  background: ${props => props.primary ? 'blue' : 'white'};
  color: ${props => props.primary ? 'white' : 'black'};
  padding: 8px 16px;
`;

// 사용
<Button primary>확인</Button>
<Button>취소</Button>
```

## 장단점

**장점**

- 컴포넌트와 스타일이 한 파일에 → **응집도 높음**
- JS 변수/로직을 스타일에 직접 활용 가능
- 클래스명 충돌 걱정 없음
- 사용하지 않는 스타일 자동 제거

**단점**

- 런타임에 스타일 계산 → **성능 오버헤드**
- JS 번들 크기 증가
- SSR 환경에서 설정 복잡
- FOUC(스타일 깜빡임) 발생 가능

## 대표 라이브러리

|라이브러리|특징|
|---|---|
|**styled-components**|가장 널리 사용, 태그드 템플릿 문법|
|**Emotion**|성능 최적화, 유연한 API|
|**Stitches**|런타임 최소화, 빠른 성능|

> 성능 문제를 해결하려는 시도에서 **제로 런타임 CSS**가 등장했습니다.