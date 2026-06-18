---
title: "Fiber Tree"
tags: [React, VirtualDOM]
status: published
---

리액트의 내부 자료구조로, 컴포넌트 트리를 Fiber 객체 단위로 표현하여 렌더링 작업을 잘게 쪼개고 우선순위에 따라 중단·재개할 수 있게 하는 구조입니다.

## Fiber 객체

각 Fiber는 다음 정보를 담습니다.
- 컴포넌트 타입, 상태([[useState]]), 훅 목록
- 부모(return) · 자식(child) · 형제(sibling) 참조
- 변경 사항을 나타내는 effect 태그 (Placement, Update, Deletion)

## Double Buffering

두 개의 트리를 운영합니다.

```
current tree      workInProgress tree
(현재 화면)  ←←←  (작업 중 — render phase에서 생성/갱신)
                        │
                  commit phase에서 교체
```

- render phase: workInProgress Fiber Tree를 생성하고 effect 태그 마킹
- commit phase: effect 리스트를 순회하며 실제 DOM에 반영 후 current ↔ workInProgress 교체

## 스케줄링과의 관계

- Fiber 단위로 작업을 분리하므로 [[동시성 모드(react)|Concurrent Mode]]에서 우선순위가 높은 작업(사용자 입력 등)이 끼어들 수 있음
- 중단된 workInProgress 트리는 나중에 이어서 처리

## 핵심 정리

Fiber Tree는 리액트 16부터 도입된 재조정(reconciliation) 엔진의 핵심으로, 동기적이던 렌더링을 비동기·중단 가능하게 만들어 [[Virtual DOM]] 비교와 실제 DOM 적용을 분리합니다.
