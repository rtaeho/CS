---
title: "Command 패턴"
tags: [디자인패턴, 객체지향, 행동패턴]
status: published
---

**요청을 객체로 캡슐화해** 실행·취소·재실행·큐잉이 가능하도록 하는 행동 디자인 패턴입니다.

## 구조

```
Client ──→ Invoker ──→ Command (interface)
                           ├── execute()
                           └── undo()
                              │
                    ┌─────────┴──────────┐
               ConcreteCommandA    ConcreteCommandB
                    │                    │
                 Receiver             Receiver
```

- **Command 인터페이스**: `execute()` / `undo()` 선언
- **ConcreteCommand**: 실제 작업과 수신자(Receiver) 참조 보유
- **Invoker**: 커맨드를 실행하고 히스토리를 관리
- **Receiver**: 실제 비즈니스 로직을 수행하는 객체

## 구현 — Undo/Redo

```java
// Command 인터페이스
interface Command {
    void execute();
    void undo();
}

// ConcreteCommand: 텍스트 삽입
class InsertCommand implements Command {
    private final StringBuilder text;
    private final int position;
    private final String value;

    InsertCommand(StringBuilder text, int position, String value) {
        this.text = text;
        this.position = position;
        this.value = value;
    }

    @Override public void execute() { text.insert(position, value); }
    @Override public void undo()    { text.delete(position, position + value.length()); }
}

// Invoker: Undo/Redo 히스토리 관리
class CommandHistory {
    private final Deque<Command> undoStack = new ArrayDeque<>();
    private final Deque<Command> redoStack = new ArrayDeque<>();

    void execute(Command cmd) {
        cmd.execute();
        undoStack.push(cmd);
        redoStack.clear();     // 새 커맨드 실행 시 redo 히스토리 초기화
    }

    void undo() {
        if (!undoStack.isEmpty()) {
            Command cmd = undoStack.pop();
            cmd.undo();
            redoStack.push(cmd);
        }
    }

    void redo() {
        if (!redoStack.isEmpty()) {
            Command cmd = redoStack.pop();
            cmd.execute();
            undoStack.push(cmd);
        }
    }
}
```

## 사용 예

```java
StringBuilder doc = new StringBuilder("Hello");
CommandHistory history = new CommandHistory();

history.execute(new InsertCommand(doc, 5, " World"));  // "Hello World"
history.execute(new InsertCommand(doc, 11, "!"));      // "Hello World!"

history.undo();   // "Hello World"
history.undo();   // "Hello"
history.redo();   // "Hello World"
```

## 언제 사용하나

- **Undo/Redo** 기능이 필요한 에디터, 드로잉 앱, 워크플로우 툴
- **매크로/배치**: 커맨드를 리스트로 모아 한 번에 실행
- **트랜잭션**: 작업 단위를 객체로 만들어 롤백 가능하게
- **큐잉/스케줄링**: 커맨드를 직렬화해 나중에 실행

## 장단점

| | 내용 |
|---|---|
| 장점 | 실행·취소 로직 분리, OCP 준수 (새 커맨드 추가 시 기존 코드 변경 없음) |
| 단점 | 커맨드 클래스 수 증가, 간단한 경우 오버엔지니어링 |

## 핵심 정리

- 요청을 객체로 만들어 execute/undo 인터페이스 제공 — Undo/Redo 스택 구현의 정석

- Invoker가 Command 히스토리를 관리, 새 커맨드 실행 시 redo 스택을 초기화하는 것이 핵심

- 전략 패턴(알고리즘 교체)과 달리 Command 패턴은 "실행 이력 관리"에 목적이 있음

→ [[SOLID]]

