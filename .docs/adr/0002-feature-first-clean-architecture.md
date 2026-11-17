# 2. Adopt Feature-First Clean Architecture

* Status: accepted
* Deciders: Core Engineering Team
* Date: 2026-11-17

Technical Story: The original codebase had code organized across loosely related top-level directories (`lib/Backend`, `lib/CurrencyTab`, `lib/Export_Screen`, `lib/HistoryTab`, `lib/UIElements`), mixing UI layout, network requests, and math logic.

## Context and Problem Statement
How should the code be structured to maximize maintainability, testability, and adherence to SOLID design principles?

## Decision Drivers
* Separation of concerns: Business logic must be testable without inflating the Flutter widget tree.
* Modularity: Features should be self-contained and independently upgradeable.
* Cognitive complexity reduction: Large monoliths like `calc_parser.dart` must be broken into single-responsibility units.

## Considered Options
* Layer-first architecture (`lib/data`, `lib/domain`, `lib/presentation` at root).
* Feature-first Clean Architecture (`lib/src/features/<feature>/{domain, data, presentation}`).
* Flat legacy organization.

## Decision Outcome
Chosen option: "Feature-first Clean Architecture", because it groups related components together while strictly enforcing layer boundaries (Domain has zero Flutter dependencies; Data encapsulates storage and network; Presentation handles UI rendering).

### Positive Consequences
* Clear boundaries for unit and widget testing.
* Domain rules are purely Dart-based and execute lightning-fast in test suites.
* High cyclomatic complexity is eliminated by delegating parsing and evaluation into focused domain classes.

### Negative Consequences
* Slightly higher number of structured subdirectories.
