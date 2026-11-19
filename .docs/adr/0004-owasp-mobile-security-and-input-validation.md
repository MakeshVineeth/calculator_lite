# 4. Enforce OWASP Mobile Security and Input Validation

* Status: accepted
* Deciders: Core Engineering Team
* Date: 2026-11-17

Technical Story: Mobile applications handling user financial calculations and sensitive operations must protect against denial of service, memory exhaustion, screen capture leakage, and insecure network transmission.

## Context and Problem Statement
How should security best practices be embedded across the application lifecycle?

## Decision Drivers
* OWASP Mobile Top 10 compliance.
* Safe user experience without telemetry or external data leakage.
* Robust error handling and bounds verification.

## Considered Options
* Ad-hoc security checks scattered across UI callbacks.
* Centralized security architecture with input validation, secure storage, and platform security flags.

## Decision Outcome
Chosen option: "Centralized security architecture":
* Input Sanitization: Mathematical expressions are validated for token length limits, bracket balancing, and valid operand sequences before parsing.
* Privacy: `FlutterWindowManager` toggles `FLAG_SECURE` to block screenshots and task switcher leaks when enabled.
* Network Security: Cleartext traffic is disabled via Android network security configuration; strict HTTPS only.

### Positive Consequences
* Immune to malformed input recursion crashes.
* No sensitive user calculations are ever leaked or transmitted off-device.
