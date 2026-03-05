데이터베이스 스키마의 변경 이력을 코드로 관리하고 버전을 추적할 수 있게 해주는 **DB 마이그레이션 도구**입니다.

## 핵심 개념

- **Changelog**: 모든 DB 변경사항을 기록하는 파일 (XML, YAML, SQL 등)
- **Changeset**: Changelog 안의 각 변경 단위 (author + id로 식별)
- **DATABASECHANGELOG**: 적용된 Changeset을 추적하는 Liquibase 전용 테이블

## 동작 방식

```
코드 변경 → Changelog 작성 → 애플리케이션 실행
                                    ↓
              DATABASECHANGELOG 테이블 확인
                    ↓               ↓
              미적용 Changeset     이미 적용됨
                    ↓
              DB에 순서대로 적용
```

## Changelog 예시

```xml
<!-- db/changelog/db.changelog-master.xml -->
<databaseChangeLog>

    <!-- v1: 테이블 생성 -->
    <changeSet id="1" author="kim">
        <createTable tableName="user">
            <column name="id" type="BIGINT" autoIncrement="true">
                <constraints primaryKey="true"/>
            </column>
            <column name="email" type="VARCHAR(255)">
                <constraints nullable="false" unique="true"/>
            </column>
        </createTable>
    </changeSet>

    <!-- v2: 컬럼 추가 -->
    <changeSet id="2" author="kim">
        <addColumn tableName="user">
            <column name="name" type="VARCHAR(100)"/>
        </addColumn>
    </changeSet>

</databaseChangeLog>
```

```java
// Spring Boot - build.gradle
implementation 'org.liquibase:liquibase-core'

// application.yml
spring:
  liquibase:
    change-log: classpath:db/changelog/db.changelog-master.xml
    enabled: true
```

## Liquibase vs Flyway

|항목|Liquibase|Flyway|
|---|---|---|
|**파일 형식**|XML, YAML, JSON, SQL|SQL, Java|
|**롤백**|✅ 지원|❌ 유료 플랜만|
|**학습 난이도**|높음|낮음|
|**유연성**|높음|낮음|
|**Spring 통합**|✅|✅|

## 장단점

**장점**

- 팀원 간 DB 스키마 변경 이력 공유 가능
- 환경별(dev/prod) 자동 적용으로 수동 DDL 실행 불필요
- 롤백 지원으로 안전한 배포 가능

**단점**

- XML/YAML 문법이 번거로움
- Changeset을 한번 적용 후 수정하면 체크섬 오류 발생
- 러닝커브가 Flyway보다 높음

> ⚠️ **주의**: 한번 적용된 Changeset은 수정하지 말 것. 변경이 필요하면 새 Changeset을 추가해야 합니다.