import 'package:flutter_test/flutter_test.dart';

final conventionalCommitRegex = RegExp(
  r'^(feat|fix|refactor|perf|test|docs|chore|style|ci|build)'
  r'(\([a-z0-9\-_\.]+\))?'
  r'(!)?'
  r': '
  r'[a-z0-9].{1,70}(?<!\.)$',
);

void main() {
  group('Conventional Commit Skill Evals', () {
    test('valid conventional commit messages pass evaluation', () {
      final validMessages = [
        'feat(calc): add scientific trigonometry support',
        'fix(currency): prevent crash on network timeout',
        'refactor(history): extract hive adapter logic into repository',
        'perf(ui): optimize custom keypad rebuilds',
        'test(calc): add comprehensive division by zero tests',
        'docs(arch): update C4 component diagram',
        'chore(deps): upgrade hive_ce to 2.23.3',
        'feat(security)!: drop support for legacy insecure storage',
      ];

      for (final msg in validMessages) {
        expect(
          conventionalCommitRegex.hasMatch(msg),
          isTrue,
          reason: 'Expected "$msg" to match conventional commit format',
        );
      }
    });

    test('invalid commit messages fail evaluation', () {
      final invalidMessages = [
        'Updated the calculator layout',
        'fix: Capitalized subject is invalid',
        'feat(calc): ends with a period.',
        'unknown(calc): invalid type',
        'feat(): empty scope',
        'fix(CALC): uppercase scope',
      ];

      for (final msg in invalidMessages) {
        expect(
          conventionalCommitRegex.hasMatch(msg),
          isFalse,
          reason: 'Expected "$msg" to be rejected',
        );
      }
    });

    test('PII detection patterns properly identify sensitive credentials', () {
      final googleKeyPattern = RegExp(r'AIza[0-9A-Za-z\-_]{35}');
      final privateKeyPattern =
          RegExp(r'-----BEGIN (?:RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----');
      final emailPattern = RegExp(
          r'\b[A-Za-z0-9._%+-]+@(?!example\.com|users\.noreply\.github\.com)[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b');

      expect(
        googleKeyPattern.hasMatch(
            'const key = "AIzaSyD-1234567890123456789012345678901";'),
        isTrue,
      );
      expect(
        privateKeyPattern.hasMatch('-----BEGIN RSA PRIVATE KEY-----'),
        isTrue,
      );
      expect(
        emailPattern.hasMatch('final user = "personal.dev@company.com";'),
        isTrue,
      );
      expect(
        emailPattern.hasMatch('final test = "user@example.com";'),
        isFalse,
      );
    });
  });
}
