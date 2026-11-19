# Architecture & Engineering Standards

## 1. Clean Architecture Overview

Calculator Lite employs a feature-first Clean Architecture pattern. Each distinct domain feature is encapsulated under `lib/src/features/<feature_name>/` and subdivided into three explicit layers:

1. **Domain Layer**:
   - Contains enterprise business rules, entities, and abstract contract specifications.
   - Zero framework dependencies (no `package:flutter/*` imports).
2. **Data Layer**:
   - Implements repository contracts specified by the domain layer.
   - Manages communication with external data providers, including Hive storage boxes and Dio HTTP clients.
3. **Presentation Layer**:
   - Contains Flutter UI widgets, screens, custom painters, and ChangeNotifier state controllers.
   - Observes state changes reactively and renders updates without business logic leaks.

---

## 2. SOLID Design Principles Implementation

- **Single Responsibility (SRP)**: Each class is dedicated to a distinct operational task (e.g. `CalculationParser` focuses strictly on token formatting, `MathEvaluator` handles evaluation, and `HistoryRepository` coordinates local storage).
- **Open/Closed (OCP)**: Math functions and operators are registered using lookup maps and strategy delegates, permitting new functions without modifying existing parsing loops.
- **Liskov Substitution (LSP)**: All data repositories conform to domain interfaces, ensuring mock implementations can seamlessly replace live data sources in testing suites.
- **Interface Segregation (ISP)**: Interfaces are kept narrow and purpose-driven (e.g., `ICurrencyService` vs `IHistoryService`).
- **Dependency Inversion (DIP)**: Presentation controllers receive repository interfaces via dependency injection rather than instantiating hardcoded singletons.
