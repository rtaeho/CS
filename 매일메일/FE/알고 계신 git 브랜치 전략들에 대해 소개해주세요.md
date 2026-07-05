---
title: "알고 계신 git 브랜치 전략들에 대해 소개해주세요"
tags: [매일메일, Frontend]
status: published
---

대표적인 [[Git 브랜치 전략]]으로는 Git Flow, GitHub Flow, Trunk-Based Development가 있습니다.

## Git Flow

Git Flow는 `main`, `develop`, `feature`, `release`, `hotfix` 브랜치를 나누어 운영합니다. 기능 개발은 `feature`에서 진행하고, 완료되면 `develop`에 병합합니다. 릴리스를 준비할 때는 `release` 브랜치에서 QA와 최종 검증을 거친 뒤 `main`에 병합합니다.

긴급 수정은 `hotfix` 브랜치에서 처리하고, 수정 사항을 `main`과 `develop`에 함께 반영합니다. 체계적인 릴리스 관리에 유리하지만 브랜치가 많아 복잡도가 높습니다.

## GitHub Flow

GitHub Flow는 `main` 브랜치를 중심으로 짧게 기능 브랜치를 만들고, Pull Request 리뷰 후 바로 `main`에 병합하는 방식입니다. 구조가 단순해 자주 배포하는 서비스에 잘 맞습니다.

다만 별도의 릴리스 브랜치나 QA 브랜치가 없으므로, `main`을 항상 배포 가능한 상태로 유지하기 위한 테스트와 리뷰가 중요합니다.

## Trunk-Based Development

Trunk-Based Development는 `main` 또는 `trunk` 브랜치에 작은 변경을 자주 병합하는 방식입니다. 장수 브랜치를 줄여 충돌 가능성을 낮추고, 기능 플래그를 활용해 아직 공개하지 않을 기능을 숨길 수 있습니다.

대신 자동화 테스트, CI/CD, 빠른 롤백 체계가 잘 갖춰져 있어야 합니다.

## 어떤 전략을 선택할까?

릴리스 주기가 길고 검증 단계가 중요한 프로젝트는 Git Flow가 적합합니다. 변경을 빠르게 배포해야 하는 웹 서비스는 GitHub Flow나 Trunk-Based Development가 더 잘 맞습니다.

## 추가 학습 자료

- [10분 테코톡 - Git 브랜칭 전략](https://www.youtube.com/watch?v=wtsr5keXUyE)
- [Git Flow에서 트렁크 기반 개발으로 나아가기](https://tech.mfort.co.kr/blog/2022-08-05-trunk-based-development/)
