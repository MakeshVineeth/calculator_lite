# 5. Reactive State Management and Comprehensive Testing Strategy

* Status: accepted
* Deciders: Core Engineering Team
* Date: 2026-11-17

Technical Story: Previously, the repository had 0 unit or widget tests. Calculation correctness and UI stability could not be verified automatically during builds.

## Context and Problem Statement
How do we structure state management to enable high-coverage unit, widget, and functional testing?

## Decision Drivers
* Testability without mocking unnecessary framework machinery.
* Predictable unidirectional data flow.
* Granular UI re-renders to maintain 60/120 FPS animations.

## Considered Options
* Direct widget `setState` everywhere.
* Full heavyweight external state management frameworks.
* Clean `ChangeNotifier` / `Provider` architecture with domain dependency injection.

## Decision Outcome
Chosen option: "Clean ChangeNotifier / Provider architecture with DI", because it is lightweight, standard to Flutter, requires no extra code generation steps, and allows pure unit testing of business logic classes.

### Positive Consequences
* Fast and isolated unit testing for math, currency, history, and export.
* Predictable state changes observable in widget tests.
* Easy substitution with mock repositories using `mocktail`.
