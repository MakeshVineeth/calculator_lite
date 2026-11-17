# 3. Replace Discontinued Packages with Native Flutter Solutions

* Status: accepted
* Deciders: Core Engineering Team
* Date: 2026-11-17

Technical Story: Several dependencies in `pubspec.yaml` were discontinued, unmaintained, or introduced unnecessary third-party risk (`slide_popup_dialog_null_safety`, `flutter_statusbarcolor_ns`, `nil`, `flutter_animator`).

## Context and Problem Statement
How do we eliminate deprecated and discontinued dependencies to ensure long-term stability, future Flutter SDK compatibility, and high performance?

## Decision Drivers
* Supply chain security (OWASP M2).
* Eliminating build failures on modern Android/iOS and newer Flutter toolchains.
* Reducing app binary bundle size.

## Considered Options
* Keep deprecated wrappers with dependency overrides.
* Fork discontinued packages into local submodules.
* Replace with native Flutter SDK primitives and custom lightweight widgets.

## Decision Outcome
Chosen option: "Replace with native Flutter SDK primitives", specifically:
* Replace `flutter_statusbarcolor_ns` with standard `SystemChrome.setSystemUIOverlayStyle`.
* Replace `slide_popup_dialog_null_safety` with standard `showModalBottomSheet`.
* Replace `nil` with `const SizedBox.shrink()`.
* Replace `flutter_animator` with a lightweight custom `AnimatedScale` bounce component.

### Positive Consequences
* Zero warnings from discontinued package notices.
* Faster compilation and smaller binary size.
* Full alignment with Material 3 theming and modern Android system bar behavior.
