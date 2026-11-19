#!/usr/bin/env python3
"""
Evals test suite for conventional-commit-and-pii-scan skill.
"""

import re
import unittest
from pathlib import Path
import sys

# Import scanner patterns directly
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from scan_pii import PATTERNS, scan_text

CONVENTIONAL_COMMIT_REGEX = re.compile(
    r"^(feat|fix|refactor|perf|test|docs|chore|style|ci|build)"
    r"(\([a-z0-9\-_\.]+\))?!"
    r": "
    r"[a-z0-9].{1,70}(?<!\.)$"
)

class TestConventionalCommitFormat(unittest.TestCase):
    def test_valid_commits(self):
        valid_messages = [
            "feat(calc): add scientific trigonometry support",
            "fix(currency): prevent crash on network timeout",
            "refactor(history): extract hive adapter logic into repository",
            "perf(ui): optimize custom keypad rebuilds",
            "test(calc): add comprehensive division by zero tests",
            "docs(arch): update C4 component diagram",
            "chore(deps): upgrade hive_ce to 2.23.3",
            "feat(security)!: drop support for legacy insecure storage",
        ]
        for msg in valid_messages:
            with self.subTest(msg=msg):
                self.assertIsNotNone(
                    CONVENTIONAL_COMMIT_REGEX.match(msg),
                    f"Message should be valid: {msg}",
                )

    def test_invalid_commits(self):
        invalid_messages = [
            "Updated the calculator layout",  # Missing type and imperative tone
            "fix: Capitalized subject is invalid",  # Capitalized subject
            "feat(calc): ends with a period.",  # Ending period
            "unknown(calc): invalid type",  # Unknown type
            "feat(): empty scope",  # Empty scope
            "fix(CALC): uppercase scope",  # Uppercase scope
        ]
        for msg in invalid_messages:
            with self.subTest(msg=msg):
                self.assertIsNone(
                    CONVENTIONAL_COMMIT_REGEX.match(msg),
                    f"Message should be invalid: {msg}",
                )

class TestPiiScanner(unittest.TestCase):
    def test_detects_google_api_key(self):
        sample = "final apiKey = 'AIzaSyD-sampleFakeKeyForTesting123456789';"
        findings = scan_text(sample, "test.dart")
        self.assertTrue(any("Google API Key" in f for f in findings))

    def test_detects_private_key(self):
        sample = "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEA..."
        findings = scan_text(sample, "key.pem")
        self.assertTrue(any("Private Key" in f for f in findings))

    def test_detects_personal_email(self):
        sample = "String developer = 'john.doe@companycorp.com';"
        findings = scan_text(sample, "author.dart")
        self.assertTrue(any("Personal Email" in f for f in findings))

    def test_allows_sanctioned_example_email(self):
        sample = "String example = 'user@example.com';"
        findings = scan_text(sample, "doc.dart")
        self.assertEqual(len(findings), 0)

    def test_allows_clean_dart_code(self):
        sample = """
        class CalculatorService {
          double add(double a, double b) => a + b;
        }
        """
        findings = scan_text(sample, "calc.dart")
        self.assertEqual(len(findings), 0)

if __name__ == "__main__":
    unittest.main()
