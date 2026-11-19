# Testing & Quality Assurance Strategy

## Overview

Calculator Lite employs a multi-tiered test pyramid to guarantee numerical accuracy, UI responsiveness, and rock-solid edge-case handling across platforms.

---

## Test Suites

### 1. Unit Tests (`test/unit/`)
- **Expression Tokenizer & Sanitizer**: Evaluates prefix/postfix operator placement, exponent notation, root symbols, and whitespace resilience.
- **Math Evaluation Engine**:
  - Basic arithmetic: addition, subtraction, multiplication, division.
  - Scientific math: trigonometric functions (`sin`, `cos`, `tan`, and inverses) in both Radian and Degree modes.
  - Advanced operations: powers, reciprocal, square roots, cube roots, percentages, factorials.
  - Edge cases: Division by zero (`Infinity` / `Error`), zero to the power of zero, negative roots, large exponentiation bounds.
- **Currency Engine**: Exchange rate scaling, inverse conversions, and error fallback scenarios.
- **Export Formatter**: Verifies CSV formatting, string escaping, and timestamp localization.

### 2. Widget & Component Tests (`test/widget/`)
- Keypad interactions: Button tap responsiveness, multi-digit sequence input, and screen display updates.
- Theme switching: Verifies appropriate background/foreground contrast across light, dark, and system modes.
- History list rendering: Empty state handling, history tile item population, and slidable action triggers.

### 3. Verification Commands
```bash
# Run all unit and widget tests
flutter test

# Run static analysis with zero warnings
flutter analyze

# Run pre-commit PII and secrets scan
dart run .agents/skills/conventional-commit/bin/scan_pii.dart
```
