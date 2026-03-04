MySQL 서버에서 발생하는 **모든 데이터 변경 이벤트(INSERT, UPDATE, DELETE, DDL)를 순서대로 기록하는 로그 파일**로, Replication과 데이터 복구의 핵심 메커니즘입니다.

## 핵심 개념

|항목|내용|
|---|---|
|**정식 명칭**|Binary Log (binlog)|
|**기록 대상**|데이터를 변경하는 모든 이벤트 (SELECT 제외)|
|**형식**|바이너리 형식 (텍스트가 아닌 이진 데이터)|
|**파일 위치**|`mysql-bin.000001`, `mysql-bin.000002`, ...|
|**주요 용도**|Replication, Point-in-Time Recovery|

## 바이너리 로그의 역할

|역할|설명|
|---|---|
|**Replication**|Master의 binlog를 Slave가 읽어서 데이터 복제|
|**데이터 복구 (PITR)**|특정 시점으로 데이터를 복원|
|**감사 (Audit)**|누가 어떤 변경을 했는지 추적|

```
[Replication에서의 역할]
Master: 데이터 변경 → Binary Log에 기록
    │
    ▼ Slave의 I/O Thread가 읽어감
    │
Slave: Relay Log에 저장 → SQL Thread가 재실행

[데이터 복구에서의 역할]
전체 백업 (어제 새벽 3시) + Binary Log (어제 3시 ~ 지금)
    → 현재 시점으로 복구 가능
```

## 바이너리 로그 기록 흐름

```
클라이언트: INSERT INTO users (name) VALUES ('홍길동')
    │
    ▼
┌──────────────────────────────────────┐
│              MySQL 서버                │
│                                      │
│  ① SQL 파싱 및 실행                    │
│  ② 스토리지 엔진(InnoDB)에 데이터 쓰기  │
│  ③ Binary Log에 이벤트 기록            │
│  ④ 클라이언트에 응답                    │
│                                      │
│  ┌────────────────────────────────┐  │
│  │      Binary Log 파일            │  │
│  │  mysql-bin.000001               │  │
│  │  ┌──────────────────────────┐  │  │
│  │  │ Event 1: CREATE TABLE... │  │  │
│  │  │ Event 2: INSERT INTO...  │  │  │
│  │  │ Event 3: UPDATE ...      │  │  │
│  │  │ Event 4: DELETE FROM...  │  │  │
│  │  │ ...                      │  │  │
│  │  └──────────────────────────┘  │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

## 바이너리 로그 포맷

| 포맷            | 기록 내용                    | 장점        | 단점                              |
| ------------- | ------------------------ | --------- | ------------------------------- |
| **STATEMENT** | 실행된 SQL 문 자체             | 로그 크기가 작음 | 비결정적 함수(NOW(), UUID()) 시 불일치 가능 |
| **ROW**       | 변경된 행 데이터 (Before/After) | 정확한 복제 보장 | 로그 크기가 큼                        |
| **MIXED**     | 기본 STATEMENT + 필요 시 ROW  | 둘의 장점 결합  | 예측하기 어려움                        |

### STATEMENT 포맷

```
-- 기록되는 내용: SQL 문 그대로
UPDATE users SET age = age + 1 WHERE id = 1;

장점: 한 줄로 끝남 (로그 작음)
단점: 아래 같은 경우 Master/Slave 결과가 다를 수 있음
      UPDATE users SET login_at = NOW() WHERE id = 1;
      → Master와 Slave의 NOW() 시간이 다름
```

### ROW 포맷

```
-- 기록되는 내용: 변경 전/후 행 데이터
### UPDATE users
### WHERE
###   @1=1        (id=1)
###   @2='홍길동'  (name='홍길동')
###   @3=25       (age=25)
### SET
###   @1=1        (id=1)
###   @2='홍길동'  (name='홍길동')
###   @3=26       (age=26)

장점: 어떤 SQL이든 정확히 같은 결과 보장
단점: UPDATE users SET age = age + 1;  (100만 행 변경)
      → 100만 행의 Before/After 모두 기록 → 로그 매우 큼
```

### 포맷 비교 예시

```
SQL: DELETE FROM logs WHERE created_at < '2025-01-01';
     (10만 행 삭제)

[STATEMENT 포맷]
기록: DELETE FROM logs WHERE created_at < '2025-01-01'
크기: 수십 바이트

[ROW 포맷]
기록: 삭제된 10만 행의 데이터 전부
크기: 수십 MB
```

## Replication에서의 동작

```
┌──────────────────────────────────────────────┐
│                  Master DB                    │
│                                              │
│  INSERT INTO orders VALUES (1001, ...)       │
│      │                                       │
│      ▼                                       │
│  Binary Log (mysql-bin.000003)               │
│  ┌────────────────────────────────────────┐  │
│  │ Position 120: BEGIN                    │  │
│  │ Position 180: INSERT INTO orders ...   │  │
│  │ Position 350: COMMIT                   │  │
│  └────────────────────────────────────────┘  │
│                    │                          │
└────────────────────┼──────────────────────────┘
                     │  Slave I/O Thread가 읽어감
                     ▼
┌──────────────────────────────────────────────┐
│                  Slave DB                     │
│                                              │
│  Relay Log                                   │
│  ┌────────────────────────────────────────┐  │
│  │ BEGIN                                  │  │
│  │ INSERT INTO orders ...                 │  │
│  │ COMMIT                                 │  │
│  └────────────────────────────────────────┘  │
│      │                                       │
│      ▼  SQL Thread가 재실행                   │
│                                              │
│  orders 테이블에 데이터 반영 완료               │
└──────────────────────────────────────────────┘
```

## Point-in-Time Recovery (PITR)

```
[시나리오: 오늘 오후 2시에 실수로 테이블 삭제]

① 전체 백업 복원 (어제 새벽 3시 백업)
   → 어제 새벽 3시 상태로 복원됨

② Binary Log 적용 (어제 3시 ~ 오늘 2시 직전까지)
   mysqlbinlog mysql-bin.000005 \
     --start-datetime="2026-03-03 03:00:00" \
     --stop-datetime="2026-03-04 13:59:59" \
     | mysql -u root -p

   → 오늘 오후 1시 59분 59초 상태로 복구 완료!
   → DROP TABLE 이벤트는 건너뜀

타임라인:
어제 3시          오늘 2시
  │  전체 백업       │ DROP TABLE (실수)
  │      │          │
  ▼      ▼          ▼
  ████████████████████
  │← 이 구간을 binlog로 복구 →│
```

## Binary Log vs 다른 로그

|로그|기록 대상|용도|레벨|
|---|---|---|---|
|**Binary Log**|데이터 변경 이벤트|Replication, PITR|MySQL 서버|
|**Redo Log**|트랜잭션 변경 사항|크래시 복구|InnoDB 엔진|
|**Undo Log**|변경 전 데이터|트랜잭션 롤백, MVCC|InnoDB 엔진|
|**General Log**|모든 SQL 쿼리|디버깅, 감사|MySQL 서버|
|**Slow Query Log**|느린 쿼리|성능 분석|MySQL 서버|

```
트랜잭션 실행 시 로그 기록 순서:

① Undo Log 기록 (변경 전 데이터 → 롤백 대비)
② 데이터 변경 (InnoDB 버퍼 풀)
③ Redo Log 기록 (크래시 복구 대비)
④ Binary Log 기록 (Replication/PITR)
⑤ COMMIT

※ Redo Log와 Binary Log 간 일관성을 위해
   2-Phase Commit(2PC)을 사용
```

## 2-Phase Commit (Redo Log + Binary Log)

```
① PREPARE 단계
   Redo Log에 PREPARE 상태로 기록

② Binary Log 기록
   Binary Log에 이벤트 기록

③ COMMIT 단계
   Redo Log에 COMMIT 상태로 기록

[크래시 복구 시]
- Redo Log: PREPARE + Binary Log: 있음 → COMMIT으로 복구
- Redo Log: PREPARE + Binary Log: 없음 → ROLLBACK
- 이를 통해 두 로그 간 일관성 보장
```

## MySQL 설정

```ini
# my.cnf

[mysqld]
# Binary Log 활성화
log-bin = mysql-bin

# 포맷 설정 (ROW 권장)
binlog_format = ROW

# 서버 ID (Replication 시 필수, 각 서버마다 고유)
server-id = 1

# Binary Log 보관 기간
binlog_expire_logs_seconds = 604800  # 7일

# Binary Log 최대 파일 크기
max_binlog_size = 100M

# 트랜잭션 안전성 (1: 매 트랜잭션마다 디스크에 동기화)
sync_binlog = 1
```

## Binary Log 조회 명령어

```sql
-- 현재 Binary Log 파일 목록
SHOW BINARY LOGS;
-- mysql-bin.000001  1.2GB
-- mysql-bin.000002  800MB
-- mysql-bin.000003  150MB  (현재 기록 중)

-- 현재 Binary Log 위치 확인
SHOW MASTER STATUS;
-- File: mysql-bin.000003, Position: 12345

-- Binary Log 이벤트 보기
SHOW BINLOG EVENTS IN 'mysql-bin.000003' LIMIT 10;
```

```bash
# 터미널에서 Binary Log 내용 확인
mysqlbinlog mysql-bin.000003

# 특정 시간 범위 필터링
mysqlbinlog mysql-bin.000003 \
  --start-datetime="2026-03-04 10:00:00" \
  --stop-datetime="2026-03-04 12:00:00"

# ROW 포맷의 상세 내용 확인
mysqlbinlog --verbose mysql-bin.000003
```