# AGENTS.md — Calculator Lite Agent Operational & Engineering Guidelines

Welcome to the **Calculator Lite** repository. This document serves as the single source of truth for AI agents and human contributors regarding architectural rules, design patterns, coding standards, security, and verification workflows.

---

## 1. Architectural Principles & SOLID Guidelines

Calculator Lite adheres strictly to **Clean Architecture** organized by **Feature-First** structure under `lib/src/`:

- **Single Responsibility Principle (SRP)**: Each class, widget, and service must have exactly one reason to change. Business logic, state management, calculation parsing, and UI rendering are strictly decoupled.
- **Open/Closed Principle (OCP)**: Math operations, token parsing, and conversion handlers use polymorphism and strategy patterns. Adding new operations must not modify existing stable evaluators.
- **Liskov Substitution Principle (LSP)**: Repositories and external service interfaces (e.g. exchange rate provider, storage provider) must be fully substitutable with test doubles/mocks.
- **Interface Segregation Principle (ISP)**: Clients depend only on focused, narrow interfaces rather than monolithic service classes.
- **Dependency Inversion Principle (DIP)**: High-level business use cases depend on abstract domain interfaces, never on concrete HTTP or Hive database implementations.

### Directory Organization
```text
lib/
  main.dart
  src/
    core/
      constants/       # Global constants, operational tokens, fixed values
      navigation/      # App routes and navigation handlers
      security/        # OWASP security utilities, sanitization, secure window manager
      storage/         # Local database abstractions & Hive initializers
      theme/           # Material 3 dynamic themes, colors, typography
      utils/           # Pure formatting and platform helpers
      widgets/         # Reusable atomic UI components (dialogs, buttons, bottom sheets)
    features/
      calculator/      # Data (parsers, evaluators), Domain (engine), Presentation (keypad, display)
      currency/        # Data (Dio client, Hive cache), Domain (rates), Presentation (cards, selector)
      history/         # Data (Hive repository), Domain (history entity), Presentation (list, edit)
      export/          # Data (CSV & Excel generation), Presentation (export dialog)
      pro_upgrade/     # Data (In-App Purchases), Presentation (paywall, status wrapper)
```

---

## 2. Code Quality & Complexity Limits

- **Cognitive & Cyclomatic Complexity**:
  - Cyclomatic complexity must not exceed **10** per function/method.
  - Cognitive complexity must not exceed **15**.
  - Avoid deeply nested `if-else` or switch cascades. Decompose complex logic into lookup maps, token stream dispatchers, or dedicated parsing rules.
- **Commentary Rule**:
  - Do NOT clutter code with verbose line-by-line commentary. Code must be expressive and self-documenting with descriptive naming.
  - Architectural rationale, trade-offs, and specifications belong in `.docs/` and Architecture Decision Records (ADRs).
- **Static Analysis & Linters**:
  - `analysis_options.yaml` is enforced at build time with strict mode (`strict-casts`, `strict-inference`, `strict-raw-types`).
  - Zero warnings, zero errors permitted on `flutter analyze`.
  - Always prefer `const` constructors and immutable models.
  - Never call `print()` in production; use structured logging or debug-only handlers.

---

## 3. OWASP Mobile Top 10 & Secure Coding Standards

1. **Input Validation (OWASP M4)**:
   - Sanitize all calculator expressions before evaluation to prevent recursion depth exhaustion, buffer abuse, or malformed sequence crashes.
   - Enforce maximum expression lengths and balance parentheses.
2. **Network Security (OWASP M5 & M8)**:
   - All external HTTP calls must use HTTPS with strict timeouts (connect, send, receive).
   - Cleartext HTTP traffic is explicitly prohibited via Android `network_security_config.xml`.
3. **Data Storage & Privacy (OWASP M6 & M9)**:
   - Calculation history and user preferences are stored locally via isolated Hive boxes.
   - Never log or transmit user calculation expressions or history to external servers.
4. **Android Platform Protections (OWASP M7 & M8)**:
   - Non-launcher activities must set `android:exported="false"`.
   - Sensitive screen protection (FLAG_SECURE) must be supported to prevent screenshot capture when enabled.
   - Backup is restricted (`android:allowBackup="false"`).

---

## 4. State Management Guidelines

- State is managed via reactive, predictable patterns (`ChangeNotifier` / `ValueNotifier` / Provider).
- Business logic is isolated from Flutter UI widgets.
- Widgets observe state via narrow listeners (`Selector` or `context.select()`) to avoid unnecessary widget rebuilds.
- State objects must properly dispose resources (`dispose()`, stream subscriptions, controllers).

---

## 5. Agent Workflow & Conventional Commits

- Agents working on this codebase must check `.agents/` for active skills and evaluation suites.
- All commits must strictly follow the **Conventional Commits 1.0.0** specification (`type(scope): description`).
- Prior to every commit, the agent must run the **PII & Secrets Scan** to verify no API tokens, emails, credentials, or private keys are introduced.
- Run `flutter analyze` and `flutter test` to ensure clean builds before completing tasks.
