`JpaEntityInformation`은 Spring Data [[JPA]]에서 **Entity의 메타데이터 정보를 제공하는 인터페이스**입니다.

## 주요 역할

```java
public interface JpaEntityInformation<T, ID> extends EntityInformation<T, ID> {
    
    // Entity가 신규인지 판단
    boolean isNew(T entity);
    
    // Entity의 ID 값 조회
    ID getId(T entity);
    
    // ID 타입 조회
    Class<ID> getIdType();
    
    // Entity 이름 조회
    String getEntityName();
    
    // ...
}
```

`SimpleJpaRepository`가 이 정보를 활용해서 `save()`, `findById()` 등을 수행합니다.

## 구현체 계층 구조

```
EntityInformation (최상위 인터페이스)
      ↓
AbstractEntityInformation (ID 기반 isNew 판단)
      ↓
JpaEntityInformation (JPA 전용 인터페이스)
      ↓
JpaMetamodelEntityInformation (기본 구현체, @Version 확인)
      ↓
JpaPersistableEntityInformation (Persistable 구현 시 사용)
```

## 어디서 사용되나?

```java
// SimpleJpaRepository 내부
public class SimpleJpaRepository<T, ID> implements JpaRepository<T, ID> {

    private final JpaEntityInformation<T, ID> entityInformation;  // ← 여기
    private final EntityManager entityManager;

    @Override
    public <S extends T> S save(S entity) {
        if (entityInformation.isNew(entity)) {  // ← 신규 판단에 사용
            entityManager.persist(entity);
            return entity;
        } else {
            return entityManager.merge(entity);
        }
    }
}
```

## 요약

| 구현체                                 | 동작 시점                      | isNew() 판단 기준       |
| ----------------------------------- | -------------------------- | ------------------- |
| [[JpaMetamodelEntityInformation]]   | 기본                         | @Version → @Id 순서   |
| [[JpaPersistableEntityInformation]] | Entity가 `Persistable` 구현 시 | `entity.isNew()` 호출 |

즉, **Entity에 대한 정보(ID, 신규 여부 등)를 추상화한 계층**이고, Spring Data JPA가 다양한 Entity를 일관되게 처리할 수 있게 해줍니다.