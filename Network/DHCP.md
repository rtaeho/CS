---
title: "DHCP"
tags: [Network, IP, DHCP]
status: published
---

DHCP(Dynamic Host Configuration Protocol)는 네트워크에 접속한 호스트에게 IP 주소와 네트워크 설정을 자동으로 임대해주는 프로토콜입니다.

## 역할

- 사용 가능한 IP 주소를 호스트에게 자동 할당합니다.
- 서브넷 마스크, 게이트웨이, DNS 서버 정보를 함께 전달할 수 있습니다.
- IP 임대 기간을 관리하고 필요하면 갱신합니다.

## DORA 과정

```text
Discover      클라이언트가 DHCP 서버를 찾음
Offer         DHCP 서버가 사용할 IP를 제안
Request       클라이언트가 제안받은 IP 사용을 요청
Acknowledgment 서버가 임대를 승인
```

## 정적 할당 vs 동적 할당

| 항목 | 정적 IP | 동적 IP(DHCP) |
|---|---|---|
| 설정 | 관리자가 수동 설정 | DHCP 서버가 자동 할당 |
| 변경 가능성 | 낮음 | 임대 갱신에 따라 변경 가능 |
| 관리 비용 | 호스트가 많으면 큼 | 상대적으로 낮음 |
| 사용 예 | 서버, 네트워크 장비 | 일반 PC, 모바일 기기 |

## 핵심 정리

DHCP는 IP 주소와 네트워크 설정을 자동으로 할당해 관리 부담과 중복 IP 설정 위험을 줄입니다.

→ [[정적 IP 주소 할당 방식과 동적 IP 주소 할당 방식의 차이점을 설명해주세요]]
