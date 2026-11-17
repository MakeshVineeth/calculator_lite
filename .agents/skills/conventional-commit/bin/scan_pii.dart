import 'dart:io';

/// Pre-commit PII and Secrets Scanner for Calculator Lite.
/// Scans files for exposed API keys, private keys, passwords, and personal emails.
void main(List<String> args) {
  final repoRoot = Directory.current;
  final patterns = <String, RegExp>{
    'Private Key': RegExp(
      r'-----BEGIN (?:RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----',
    ),
    'Generic Secret': RegExp(
      r'(?:api_key|apikey|secret_key|app_secret|auth_token)\s*[:=]\s*[\x27\x22][0-9a-zA-Z\-_]{16,}[\x27\x22]',
      caseSensitive: false,
    ),
    'Google API Key': RegExp(r'AIza[0-9A-Za-z\-_]{35}'),
    'GitHub Token': RegExp(r'(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,255}'),
    'AWS Access Key': RegExp(r'(?:AKIA|ASIA)[0-9A-Z]{16}'),
    'Bearer Token': RegExp(
      r'bearer\s+[a-zA-Z0-9_\-\.]{20,}',
      caseSensitive: false,
    ),
    'Personal Email': RegExp(
      r'\b[A-Za-z0-9._%+-]+@(?!example\.com|users\.noreply\.github\.com)[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
      caseSensitive: false,
    ),
    'Hardcoded Password': RegExp(
      r'(?:password|passwd|pwd)\s*[:=]\s*[\x27\x22][^\x27\x22]{6,}[\x27\x22]',
      caseSensitive: false,
    ),
  };

  final targetDirs = ['lib', 'test', 'android/app/src'];
  final findings = <String>[];
  int filesScanned = 0;

  for (final dirName in targetDirs) {
    final dir = Directory('${repoRoot.path}/$dirName');
    if (!dir.existsSync()) continue;

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File) continue;
      final path = entity.path;
      if (path.endsWith('.png') ||
          path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.zip') ||
          path.endsWith('.ico') ||
          path.endsWith('.g.dart') ||
          path.contains('.git')) {
        continue;
      }

      filesScanned++;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('ALLOW_PII_TEST')) continue;

        for (final entry in patterns.entries) {
          if (entry.value.hasMatch(line)) {
            findings.add(
              '[${entry.key}] $path:${i + 1} - ${line.trim()}',
            );
          }
        }
      }
    }
  }

  if (findings.isNotEmpty) {
    stderr.writeln('\n❌ PII / Secrets Scan FAILED! Potential sensitive data found:');
    for (final item in findings) {
      stderr.writeln('  - $item');
    }
    stderr.writeln('\nPlease sanitize before committing.\n');
    exit(1);
  } else {
    stdout.writeln('✅ PII & Secrets scan clean: $filesScanned files checked. No secrets found.');
    exit(0);
  }
}
