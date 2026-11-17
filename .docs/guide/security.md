# OWASP Mobile Top 10 Security Architecture

Calculator Lite implements rigorous defensive engineering adhering to the **OWASP Mobile Application Security Verification Standard (MASVS)** and OWASP Mobile Top 10 guidelines.

---

## Security Controls Matrix

| OWASP Mobile Threat | Defensive Implementation | Verification Method |
|---|---|---|
| **M1: Improper Credential Usage** | Zero hardcoded API keys or static bearer tokens. All external rate lookups use unauthenticated public tier endpoints or client-injected runtime configs. | Static code analysis & pre-commit PII scan |
| **M2: Inadequate Supply Chain Security** | Explicit dependency pinning, removal of unmaintained packages (`flutter_animator`, `slide_popup_dialog_null_safety`, `flutter_statusbarcolor_ns`). | `flutter pub outdated` & vulnerability audit |
| **M3: Insecure Authentication/Authorization** | App does not require backend user accounts; all calculation data resides locally on the user's sandboxed device. | Architecture review |
| **M4: Insufficient Input/Output Validation** | All mathematical expressions are bounded in length (max 200 tokens), validated against strict syntax regexes, checked for balanced parentheses, and guarded against division by zero and numerical overflow. | Automated unit & fuzzing tests |
| **M5: Insecure Communication** | Strict HTTPS enforcement with TLS 1.3/1.2; Android network security config explicitly disables cleartext traffic (`cleartextTrafficPermitted="false"`). | Android manifest verification |
| **M6: Inadequate Privacy Controls** | Zero telemetry, zero analytics tracking, zero crash reporters sending data to third parties. History and calculations never leave the device. | Network inspection & source code review |
| **M7: Insufficient Binary Protections** | Supports `FLAG_SECURE` mode via `FlutterWindowManager` to prevent screen recording, task switcher previews, and unauthorized screenshots of financial/calculation history. | Manual QA & integration tests |
| **M8: Security Misconfiguration** | Disabled unnecessary permissions (`READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` replaced by standard scoped storage APIs); explicit `android:exported="false"` on non-launcher activities. | Android lint & manifest scan |
| **M9: Insecure Data Storage** | User history and preferences are stored strictly in private sandboxed application storage via Hive (`getApplicationDocumentsDirectory`). | File system inspection on rooted emulator |
| **M10: Insufficient Cryptography** | Relies on verified OS cryptographic primitives for secure operations and system TLS handshakes. | Dependency & platform review |
