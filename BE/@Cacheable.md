Spring에서 메서드의 실행 결과를 캐시에 저장하고, 동일한 요청이 오면 메서드를 실행하지 않고 캐시된 결과를 반환하는 어노테이션입니다.

## 동작 흐름

```
요청 → 캐시에 데이터 있음? → Yes → 캐시된 값 반환 (메서드 실행 X)
                            → No  → 메서드 실행 → 결과를 캐시에 저장 → 반환
```

## 기본 사용 예시

```java
@Service
public class ProductService {

    @Cacheable(value = "products", key = "#id")
    public Product getProduct(Long id) {
        // 첫 호출 시에만 DB 조회, 이후 캐시에서 반환
        return productRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("상품 없음"));
    }
}
```

## 주요 캐시 어노테이션

|어노테이션|설명|
|---|---|
|**@Cacheable**|캐시가 있으면 반환, 없으면 실행 후 저장|
|**@CachePut**|항상 메서드를 실행하고 결과를 캐시에 갱신|
|**@CacheEvict**|캐시에서 데이터를 삭제|
|**@Caching**|여러 캐시 어노테이션을 조합하여 사용|

```java
@Service
public class ProductService {

    @Cacheable(value = "products", key = "#id")
    public Product getProduct(Long id) {
        return productRepository.findById(id).orElseThrow();
    }

    @CachePut(value = "products", key = "#product.id")
    public Product updateProduct(Product product) {
        return productRepository.save(product);  // 실행 후 캐시도 갱신
    }

    @CacheEvict(value = "products", key = "#id")
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);  // 삭제 후 캐시도 제거
    }

    @CacheEvict(value = "products", allEntries = true)
    public void clearAllProductCache() {
        // products 캐시 전체 삭제
    }
}
```

## 주요 속성

|속성|설명|예시|
|---|---|---|
|**value**|캐시 이름|`"products"`|
|**key**|캐시 키 (SpEL 표현식)|`"#id"`, `"#product.name"`|
|**condition**|캐싱 조건|`"#id > 10"`|
|**unless**|결과 기반 캐싱 제외 조건|`"#result == null"`|
|**cacheManager**|사용할 캐시 매니저 지정|`"redisCacheManager"`|

```java
@Cacheable(
    value = "products",
    key = "#id",
    condition = "#id > 0",          // id가 0 이하이면 캐싱하지 않음
    unless = "#result == null"       // 결과가 null이면 캐싱하지 않음
)
public Product getProduct(Long id) {
    return productRepository.findById(id).orElse(null);
}
```

## 캐시 저장소 종류

|저장소|특징|
|---|---|
|**ConcurrentMapCache**|Spring 기본 내장, 로컬 메모리, 별도 설정 불필요|
|**Caffeine**|고성능 로컬 캐시, TTL/최대 크기 설정 가능|
|**Redis**|분산 환경에서 서버 간 캐시 공유, 가장 널리 사용|
|**EhCache**|JVM 기반 로컬 캐시, XML 설정 지원|

## Redis 캐시 설정 예시

```java
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public RedisCacheManager redisCacheManager(RedisConnectionFactory factory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(30))           // TTL 30분
                .disableCachingNullValues()                   // null 캐싱 방지
                .serializeValuesWith(
                    SerializationPair.fromSerializer(new GenericJackson2JsonRedisSerializer())
                );

        return RedisCacheManager.builder(factory)
                .cacheDefaults(config)
                .build();
    }
}
```

## ⚠️ 주의사항

|주의점|설명|
|---|---|
|**프록시 기반**|`@Transactional`과 동일하게 내부 호출(self-invocation) 시 캐시 미적용|
|**키 설계**|키가 동일하면 다른 파라미터여도 같은 캐시를 반환하므로 키 설계가 중요|
|**직렬화**|Redis 등 외부 캐시 사용 시 객체가 `Serializable`이어야 함|
|**캐시 일관성**|데이터 변경 시 `@CacheEvict` 또는 `@CachePut`으로 캐시 동기화 필요|
|**TTL 설정**|TTL 없으면 오래된 데이터가 계속 남으므로 적절한 만료 시간 설정 필수|
