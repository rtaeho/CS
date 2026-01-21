JPA [[N+1 문제]]는 연관 관계가 설정된 엔티티를 조회할 경우에, 조회된 데이터 개수(N)만큼 연관관계의 조회 쿼리가 추가로 발생하는 현상입니다. 예를 들어, 블로그 게시글과 댓글이 있는 경우, 게시글을 조회한 후 각 게시글마다 댓글을 조회하기 위한 추가 쿼리가 발생할 수 있습니다. 이를 N + 1 문제라고 합니다.

## [](https://www.maeil-mail.kr/question/49#findall-%EB%A9%94%EC%84%9C%EB%93%9C%EC%9D%98-%EA%B8%80%EB%A1%9C%EB%B2%8C-%ED%8C%A8%EC%B9%98-%EC%A0%84%EB%9E%B5-%EB%B3%84-n--1-%EB%AC%B8%EC%A0%9C-%EC%83%81%ED%99%A9%EC%97%90-%EB%8C%80%ED%95%B4%EC%84%9C-%EC%84%A4%EB%AA%85%ED%95%B4%EC%A3%BC%EC%84%B8%EC%9A%94-)findAll 메서드의 글로벌 패치 전략 별 N + 1 문제 상황에 대해서 설명해주세요. 🤓

> spring data jpa에서 제공하는 repository의 findAll 메서드입니다!

글로벌 패치 전략을 즉시로딩으로 설정하고 findAll()을 실행하면 N + 1 문제가 발생합니다. 이는 findAll()은 `select u from User u`라는 JPQL 구문을 생성해서 실행하기 때문입니다. JPQL은 글로벌 패치 전략을 고려하지 않고 쿼리를 실행합니다. 모든 User를 조회하는 쿼리 실행 후, 즉시로딩 설정을 보고 연관관계에 있는 모든 엔티티를 조회하는 쿼리를 실행합니다.

글로벌 패치 전략을 지연 로딩으로 설정하고 findAll()을 실행하면 N + 1 문제가 발생하지 않습니다. 이는 연관관계에 있는 엔티티를 실제 객체 대신에 프록시 객체로 생성하여 주입하기 때문입니다. 하지만 프록시 객체를 사용할 경우에 실제 데이터가 필요하여 조회하는 쿼리가 발생하고 N + 1 문제가 발생할 수 있습니다.

## [](https://www.maeil-mail.kr/question/49#n--1-%EB%AC%B8%EC%A0%9C%EB%8A%94-%EC%96%B4%EB%96%BB%EA%B2%8C-%ED%95%B4%EA%B2%B0%ED%95%A0-%EC%88%98-%EC%9E%88%EC%9D%84%EA%B9%8C%EC%9A%94-)N + 1 문제는 어떻게 해결할 수 있을까요? 🤔

N + 1 문제를 해결하기 위해서는 `fetch join`, `@EntityGraph`를 사용해 볼 수 있습니다. `fetch join`은 연관 관계에 있는 엔티티를 한번에 즉시 로딩하는 구문입니다. `@EntityGraph`도 비슷한 효과를 만들어내며, 쿼리 메서드에 해당 어노테이션을 추가해 사용할 수 있습니다.

```sql
select distinct u
from User u
left join fetch u.posts
```

```java
@EntityGraph(attributePaths = {"posts"}, type = EntityGraphType.FETCH)
List<User> findAll();
```
