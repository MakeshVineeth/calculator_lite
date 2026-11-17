---
name: clean-architecture-and-solid-standards
description: Enforces SOLID design principles, clean architecture layer isolation, and Flutter recommended patterns.
version: 1.0.0
---

# Clean Architecture & SOLID Standards Skill

## Purpose
Enforces modular feature-first Clean Architecture, strict SOLID adherence, and complexity management for all features added or modified in Calculator Lite.

## Rules & Invariants
1. **Layer Separation**:
   - `domain/`: Pure business logic, value objects, entities, and abstract repository contracts. No Flutter UI imports (`package:flutter/*` is forbidden in domain layer).
   - `data/`: Concrete implementations of repository contracts, data sources (Hive, Dio, SharedPrefs), DTOs, and adapters.
   - `presentation/`: Flutter widgets, state notifiers, view models, and controllers. No direct calls to network or low-level file I/O.
2. **SOLID Principles**:
   - **SRP**: Functions must perform a single focused task. Keypad layout, display formatting, and calculation execution are isolated.
   - **OCP**: Evaluators and token processors are extensible via polymorphic visitor/strategy patterns.
   - **LSP**: All repository contracts must be mockable and substitutable.
   - **ISP**: Interfaces must have minimal surface area.
   - **DIP**: High-level presentation and domain rely on abstract interfaces, injected via constructors.
3. **Complexity Ceiling**:
   - Max cyclomatic complexity: 10 per method.
   - Max cognitive complexity: 15 per method.
   - If a method exceeds these limits, decompose into helper transformers or rule classes.
