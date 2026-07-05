---
title: "Git 브랜치 전략"
tags: [Git, 브랜치, 협업]
status: published
---

Git 브랜치 전략은 여러 개발자가 기능 개발, 릴리스, 긴급 수정 작업을 안정적으로 병렬 처리하기 위해 브랜치를 운영하는 규칙입니다.

## Git Flow

Git Flow는 `main`, `develop`, `feature`, `release`, `hotfix` 브랜치를 나누어 운영하는 전략입니다.

- 기능 개발은 `feature` 브랜치에서 진행합니다.
- 완료된 기능은 `develop`에 병합합니다.
- 배포 준비는 `release` 브랜치에서 검증합니다.
- 긴급 수정은 `hotfix` 브랜치에서 처리한 뒤 `main`과 `develop`에 반영합니다.

릴리스 주기가 길고 QA 단계가 명확한 프로젝트에 어울립니다. 대신 브랜치가 많아 운영 비용이 큽니다.

## GitHub Flow

GitHub Flow는 `main` 브랜치를 중심으로 짧은 기능 브랜치를 만들고, 리뷰 후 바로 `main`에 병합하는 단순한 전략입니다.

- `main`은 항상 배포 가능한 상태여야 합니다.
- 작업 단위별 브랜치를 만들고 Pull Request로 리뷰합니다.
- 병합 후 바로 배포하거나 배포 파이프라인을 실행합니다.

배포 주기가 짧고 CI/CD가 잘 갖춰진 서비스에 잘 맞습니다.

## Trunk-Based Development

Trunk-Based Development는 `main` 또는 `trunk`에 작은 변경을 자주 병합하는 전략입니다.

- 장수 브랜치를 피합니다.
- 기능 플래그로 미완성 기능을 숨길 수 있습니다.
- 자동화 테스트와 빠른 배포 파이프라인이 중요합니다.

충돌을 줄이고 배포 속도를 높일 수 있지만, 테스트 자동화와 코드 리뷰 문화가 약하면 위험할 수 있습니다.

## 비교

| 전략 | 특징 | 적합한 상황 |
|---|---|---|
| Git Flow | 역할별 브랜치가 명확함 | 릴리스 주기가 길고 QA가 중요한 프로젝트 |
| GitHub Flow | 단순한 main 중심 흐름 | 짧은 배포 주기, 웹 서비스 |
| Trunk-Based Development | 작은 변경을 trunk에 자주 병합 | 강한 CI/CD와 기능 플래그가 있는 팀 |

## 핵심 정리

브랜치 전략은 정답이 하나로 정해져 있지 않습니다.

릴리스 주기, QA 방식, 팀 규모, 자동화 수준에 맞춰 Git Flow, GitHub Flow, Trunk-Based Development 중 적절한 방식을 선택해야 합니다.

→ [[알고 계신 git 브랜치 전략들에 대해 소개해주세요]]
