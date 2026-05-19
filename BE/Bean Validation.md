객체 필드에 선언한 어노테이션만으로 입력값을 자동 검증하는 Java 표준 스펙(JSR-380)으로, Spring에서는 `@Valid` / `@Validated`로 활성화합니다.

## 주요 어노테이션

| 어노테이션 | 설명 |
|---|---|
| `@NotNull` | null 불허 |
| `@NotBlank` | null·빈 문자열·공백 불허 (String 전용) |
| `@NotEmpty` | null·빈 컬렉션/문자열 불허 |
| `@Size(min, max)` | 길이/크기 범위 |
| `@Min` / `@Max` | 숫자 최솟값/최댓값 |
| `@Email` | 이메일 형식 |
| `@Pattern(regexp)` | 정규식 |

## @Valid vs @Validated

| | `@Valid` | `@Validated` |
|---|---|---|
| 출처 | Jakarta EE 표준 | Spring 전용 |
| 그룹 검증 | ❌ | ✅ |
| 중첩 객체 검증 | ✅ | ❌ |
| Service AOP 적용 | ❌ | ✅ (클래스 레벨 선언) |

## 사용 예

```java
public class SignUpRequest {
    @NotBlank
    private String name;

    @Email
    private String email;

    @Size(min = 8, max = 20)
    private String password;
}

@PostMapping("/signup")
public ResponseEntity<?> signUp(@RequestBody @Valid SignUpRequest request) {
    // 검증 실패 시 MethodArgumentNotValidException 자동 throw
}
```

## 주의사항

- `@Valid` 없이 `@RequestBody`만 쓰면 검증 실행 안 됨
- `@NotBlank`은 String 전용, 컬렉션은 `@NotEmpty` 사용
- 중첩 DTO 검증 시 해당 필드에도 `@Valid` 추가 필요
- Service 계층에서 사용하려면 클래스에 `@Validated` 선언 필요

→ [[Spring AOP]]
