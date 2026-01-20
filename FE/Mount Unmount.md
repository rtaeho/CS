## 마운트 (Mount)

컴포넌트가 화면(DOM)에 **추가되는 것**입니다.

## 언마운트 (Unmount)

컴포넌트가 화면(DOM)에서 **제거되는 것**입니다.

## 예시

```jsx
{showProfile && <Profile />}
```

- `showProfile`이 `true` → Profile 마운트 (화면에 나타남)
- `showProfile`이 `false` → Profile 언마운트 (화면에서 사라짐)

## 프레임워크별 훅

|프레임워크|마운트|언마운트|
|---|---|---|
|React|`useEffect`|`useEffect` return|
|Vue|`onMounted`|`onUnmounted`|
|Angular|`ngOnInit`|`ngOnDestroy`|
|Svelte|`onMount`|`onDestroy`|

## 어원

"Mount"는 장착하다라는 뜻입니다. OS에서 USB를 마운트/언마운트하는 것과 같은 개념으로, 컴포넌트를 DOM 트리에 장착/제거한다는 의미입니다.