`JpaMetamodelEntityInformation`은 **[[JPA]] Metamodel을 사용해서 Entity 정보를 추출하는 기본 구현체**입니다.

## JPA Metamodel이란?

JPA가 Entity 클래스를 분석해서 만들어놓은 **메타데이터 모델**입니다.

```java
@Entity
public class Member {
    @Id
    private Long id;
    
    @Version
    private Long version;
    
    private String name;
}
```

이 Entity를 JPA가 분석하면:

- ID 필드가 뭔지 (`id`)
- Version 필드가 뭔지 (`version`)
- 각 필드의 타입이 뭔지

이런 정보들을 Metamodel로 보관합니다.

## JpaMetamodelEntityInformation의 역할

Metamodel에서 정보를 꺼내와서 `EntityInformation` 인터페이스를 구현합니다.

```java
public class JpaMetamodelEntityInformation<T, ID> 
        extends AbstractEntityInformation<T, ID> 
        implements JpaEntityInformation<T, ID> {

    private final IdMetadata<T> idMetadata;           // @Id 정보
    private final Optional<SingularAttribute<? super T, ?>> versionAttribute;  // @Version 정보
    
    @Override
    public boolean isNew(T entity) {
        // 1) @Version 필드가 없거나 primitive면 → 부모 클래스(ID 기반)로 위임
        if (versionAttribute.isEmpty()
              || versionAttribute.map(Attribute::getJavaType)
                                 .map(Class::isPrimitive).orElse(false)) {
            return super.isNew(entity);
        }
        
        // 2) @Version 필드가 Wrapper 타입이면 → null 여부로 판단
        BeanWrapper wrapper = new DirectFieldAccessFallbackBeanWrapper(entity);
        return versionAttribute
                .map(it -> wrapper.getPropertyValue(it.getName()) == null)
                .orElse(true);
    }
    
    @Override
    public ID getId(T entity) {
        // Metamodel에서 @Id 필드 정보를 가져와서 값 추출
        // ...
    }
}
```

## 동작 흐름

```
Entity 클래스 로딩
       ↓
JPA Metamodel 생성 (Entity 분석)
       ↓
JpaMetamodelEntityInformation 생성 (Metamodel 활용)
       ↓
SimpleJpaRepository에서 사용
```

## 요약

|항목|설명|
|---|---|
|**역할**|JPA Metamodel 기반으로 Entity 정보 제공|
|**사용 시점**|Entity가 `Persistable`을 구현하지 않은 경우 (기본)|
|**isNew() 판단**|@Version → @Id 순서로 확인|
|**정보 출처**|JPA Metamodel (런타임에 Entity 분석 결과)|

즉, **JPA가 Entity를 분석한 결과(Metamodel)를 활용해서 Spring Data JPA가 필요한 정보를 제공하는 클래스**입니다.