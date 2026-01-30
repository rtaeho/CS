Spring MVC에서 HTTP 요청을 처리하는 프레젠테이션 계층 빈을 등록하는 [[어노테이션]]입니다. 클라이언트 요청을 받아 응답을 반환합니다.

## 기본 사용법

```java
@Controller
public class UserController {
    
    @GetMapping("/users")
    public String list(Model model) {
        model.addAttribute("users", userService.findAll());
        return "user/list";  // 뷰 이름 반환 → HTML 렌더링
    }
}
```

## 동작 흐름

```
클라이언트 요청
    ↓
DispatcherServlet
    ↓
@Controller (요청 처리)
    ↓
ViewResolver (뷰 이름 → 실제 뷰)
    ↓
HTML 응답
```

## @Controller vs @RestController

|항목|@Controller|@RestController|
|---|---|---|
|반환|뷰 이름 (HTML)|데이터 (JSON)|
|용도|SSR (서버 사이드 렌더링)|REST API|
|내부|@Component|@Controller + @ResponseBody|

```java
// @Controller - HTML 반환
@Controller
public class ViewController {
    @GetMapping("/page")
    public String page() {
        return "page";  // templates/page.html
    }
}

// @RestController - JSON 반환
@RestController
public class ApiController {
    @GetMapping("/api/users")
    public List<User> users() {
        return userService.findAll();  // JSON으로 변환
    }
}
```

## @Controller에서 JSON 반환하려면

```java
@Controller
public class UserController {
    
    // @ResponseBody 추가
    @GetMapping("/api/users")
    @ResponseBody
    public List<User> users() {
        return userService.findAll();  // JSON 반환
    }
}
```

## 주요 어노테이션

```java
@Controller
@RequestMapping("/users")
public class UserController {
    
    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        model.addAttribute("user", userService.findById(id));
        return "user/detail";
    }
    
    @PostMapping
    public String create(@ModelAttribute UserForm form) {
        userService.save(form);
        return "redirect:/users";
    }
}
```

|어노테이션|용도|
|---|---|
|`@RequestMapping`|URL 매핑 (클래스/메서드)|
|`@GetMapping`|GET 요청|
|`@PostMapping`|POST 요청|
|`@PathVariable`|URL 경로 변수|
|`@RequestParam`|쿼리 파라미터|
|`@ModelAttribute`|폼 데이터 바인딩|

## 왜 @Component 대신 @Controller 쓰나?

```java
// 동작은 하지만 권장하지 않음
@Component
public class UserController { }

// 권장
@Controller
public class UserController { }
```

- 웹 계층임을 명시
- Spring MVC가 핸들러로 인식
- 뷰 리졸버 연동