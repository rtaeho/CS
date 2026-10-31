---
title: 앤트로픽의 AI for Science 프로그램 확장
tags: [AI소식, 과학, 에이전트]
status: published
---

앤트로픽이 과학 재단·연구기관 20곳과 파트너십을 맺어 연구자에게 Claude 크레딧을 지원하는 AI for Science 프로그램을 확장했다.
기준 시점: 2026-10-28

## 무슨 일인가

앤트로픽 뉴스룸 발표에 따르면 AI for Science 프로그램은 2025년 5월에 시작됐고, 그동안 생물학·의학·물리학·화학·기후과학·수학 분야의 수백 개 프로젝트를 지원해 왔다. 이번 발표는 지원 대상을 개별 연구자 단위에서 재단·기관 단위로 넓혀, Alfred P. Sloan Foundation·Simons Foundation·Schmidt Sciences·미국 국립과학재단(NSF)·Wellcome Sanger Institute·Francis Crick Institute·EMBL 등 20개 조직과의 협력을 공개한 것이다.

발표문은 여러 파트너 프로젝트에서 쓰이는 구체적인 기법도 소개했다.

- HHMI Janelia Research Campus와 함께 만든 **Model Hardware Standard(MHS)** — AI 에이전트가 실험실 장비를 안전하게 직접 조작할 수 있게 하는 공유 규격으로, 현재 리서치 프리뷰 단계다.
- Allen Institute는 대규모 뇌·세포·면역 데이터셋을 분석하는 데 여러 AI 에이전트로 구성된 팀을 구성하고 있다.
- Tau Ceti는 컴퓨터가 증명을 검증할 수 있는 언어인 Lean으로 수학 라이브러리를 구축하는 데 오토포멀라이제이션(autoformalization)을 쓰고 있다.
- LEAP는 기후 모델의 구름·해양·육지 표현을 개선하는 데 머신러닝과 물리 모델을 결합하고 있다.

## 왜 중요한가

지금까지 AI for Science는 개별 연구자에게 크레딧을 주는 방식이었는데, 이번에 재단·기관 단위로 넓어지면서 한 기관의 협력이 그 아래 여러 연구 그룹으로 자연스럽게 퍼지는 구조가 됐다. 특히 MHS처럼 "에이전트가 소프트웨어 툴이 아니라 물리 장비를 직접 조작하는" 영역에 표준을 두려는 시도가 눈에 띈다. 지금까지 에이전트 툴 프로토콜(MCP, A2A 등)은 대부분 소프트웨어 간 호출을 다뤘는데, MHS는 그 경계를 실험실 하드웨어까지 넓히는 사례로 볼 수 있다.

## 짚고 갈 개념

- Model Hardware Standard(MHS) — AI 에이전트가 실험실 장비를 안전하게 직접 조작하도록 하는 공유 규격, 현재 리서치 프리뷰

## 내 생각

MHS가 아직 리서치 프리뷰 단계라 구체적인 안전 보증 방식(권한 범위, 실패 시 복구 절차 등)이 공개 문서에 자세히 나오지 않은 것으로 보인다. 소프트웨어 툴 호출과 달리 물리 장비 조작은 되돌릴 수 없는 결과(시료 손상, 장비 오작동)를 낼 수 있어서, MCP류 프로토콜보다 권한 모델과 승인 루프가 훨씬 중요해질 것으로 보인다.

## 출처

- https://www.anthropic.com/news/ai-for-science-expands-foundations-research-institutions
