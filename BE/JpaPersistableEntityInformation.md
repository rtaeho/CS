`JpaPersistableEntityInformation`은 **Entity가 `Persistable` 인터페이스를 구현했을 때 사용되는 구현체**입니다.

## Persistable 인터페이스

```java
public interface Persistable<ID> {
    ID getId();
    boolean isNew();
}
```

Entity가 이 인터페이스를 구현하면, **신규 여부를 Entity 스스로 결정**할 수 있습니다.

## JpaPersistableEntityInformation 구조

```java
public class JpaPersistableEntityInformation<T extends Persistable<ID>, ID>
        extends JpaMetamodelEntityInformation<T, ID> {

    @Override
    public boolean isNew(T entity) {
        return entity.isNew();  // Entity에게 직접 물어봄
    }

    @Override
    public ID getId(T entity) {
        return entity.getId();  // Entity에게 직접 물어봄
    }
}
```

`JpaMetamodelEntityInformation`을 상속하면서, **isNew()와 getId()만 오버라이드**합니다.

## 언제 사용되나?

ID를 직접 할당하는 경우에 필요합니다.

```java
@Entity
public class Item implements Persistable<String> {
    
    @Id
    private String id;  // 직접 할당 (UUID 등)
    
    @CreatedDate
    private LocalDateTime createdDate;
    
    public Item(String id) {
        this.id = id;  // 생성 시점에 ID 할당
    }
    
    @Override
    public String getId() {
        return id;
    }
    
    @Override
    public boolean isNew() {
        return createdDate == null;  // 생성일 없으면 신규
    }
}
```

## 비교

|구현체|사용 조건|isNew() 판단|
|---|---|---|
|`JpaMetamodelEntityInformation`|기본 (Persistable 미구현)|@Version → @Id 확인|
|`JpaPersistableEntityInformation`|Entity가 `Persistable` 구현|`entity.isNew()` 호출|

## 왜 필요한가?

```java
// ID 직접 할당 + Persistable 미구현
Item item = new Item("ITEM-001");
itemRepository.save(item);

// 문제: id가 이미 있으므로 신규로 판단 안 됨
// → merge() 호출 → 불필요한 SELECT 발생
```

```java
// ID 직접 할당 + Persistable 구현
Item item = new Item("ITEM-001");
itemRepository.save(item);

// isNew()가 true 반환 (createdDate == null)
// → persist() 호출 → SELECT 없이 바로 INSERT
```

## 요약

**Entity가 직접 "나 신규야/아니야"를 알려줄 수 있게 해주는 구현체**입니다. ID를 직접 할당하는 상황에서 불필요한 SELECT를 방지하려면 `Persistable`을 구현해야 합니다.