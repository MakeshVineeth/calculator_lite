#!/usr/bin/env python3
"""
Pre-commit PII and Secrets Scanner for Calculator Lite.
Detects potential API keys, private keys, passwords, personal emails, and sensitive credentials.
"""

import sys
import re
import os
import subprocess
from pathlib import Path

# Compiled regex patterns for PII and sensitive credentials
PATTERNS = {
    "Private Key": re.compile(r"-----BEGIN (?:RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----"),
    "Generic API Key / Token": re.compile(r"(?i)(?:api_key|apikey|secret_key|app_secret|auth_token)\s*[:=]\s*['\"][0-9a-zA-Z\-_]{16,}['\"]"),
    "Google API Key": re.compile(r"AIza[0-9A-Za-z\-_]{35}"),
    "GitHub Token": re.compile(r"(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,255}"),
    "AWS Access Key": re.compile(r"(?:AKIA|ASIA)[0-9A-Z]{16}"),
    "Bearer Token": re.compile(r"(?i)bearer\s+[a-zA-Z0-9_\-\.]{20,}"),
    "Personal Email": re.compile(r"\b[A-Za-z0-9._%+-]+@(?!example\.com|users\.noreply\.github\.com)[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b"),
    "Hardcoded Password": re.compile(r"(?i)(?:password|passwd|pwd)\s*[:=]\s*['\"][^'\"]{6,}['\"]"),
}

EXCLUDED_DIRS = {
    ".git",
    ".idea",
    ".vscode",
    "build",
    ".dart_tool",
    "node_modules",
    ".gradle",
}

EXCLUDED_EXTENSIONS = {
    ".png",
    ".jpg",
    ".jpeg",
    ".ico",
    ".zip",
    ".jar",
    ".lock",
}

def scan_text(content: str, file_path: str) -> list[str]:
    findings = []
    lines = content.splitlines()
    for line_idx, line in enumerate(lines, start=1):
        for name, pattern in PATTERNS.items():
            if pattern.search(line):
                # Ignore comment hints in tests or evals if explicitly marked
                if "ALLOW_PII_TEST" in line:
                    continue
                findings.append(f"[{name}] {file_path}:{line_idx} - {line.strip()[:60]}...")
    return findings

def get_staged_or_modified_files(repo_root: Path) -> list[Path]:
    try:
        res = subprocess.run(
            ["git", "diff", "--name-only", "HEAD"],
            cwd=str(repo_root),
            capture_output=True,
            text=True,
            check=False,
        )
        if res.returncode == 0 and res.stdout.strip():
            files = [repo_root / p.strip() for p in res.stdout.strip().splitlines() if p.strip()]
            return [f for f in files if f.is_file()]
    except Exception:
        pass
    
    # Fallback to scanning all tracked code files in lib/, test/, and android/
    files = []
    for search_dir in ["lib", "test", "android/app/src"]:
        target_path = repo_root / search_dir
        if target_path.exists():
            for root, dirs, filenames in os.walk(target_path):
                dirs[:] = [d for d in dirs if d not in EXCLUDED_DIRS]
                for fn in filenames:
                    p = Path(root) / fn
                    if p.suffix.lower() not in EXCLUDED_EXTENSIONS:
                        files.append(p)
    return files

def main():
    repo_root = Path(__file__).resolve().parents[3]
    files_to_scan = get_staged_or_modified_files(repo_root)
    
    total_findings = []
    for file_path in files_to_scan:
        try:
            content = file_path.read_text(encoding="utf-8", errors="ignore")
            rel_path = file_path.relative_to(repo_root)
            findings = scan_text(content, str(rel_path))
            total_findings.extend(findings)
        except Exception as e:
            print(f"Warning: Could not read {file_path}: {e}", file=sys.stderr)
            
    if total_findings:
        print("\n❌ PII / Secrets Scan FAILED! Sensitive data detected:\n", file=sys.stderr)
        for finding in total_findings:
            print(f"  - {finding}", file=sys.stderr)
        print("\nPlease remove or sanitize these entries before committing.\n", file=sys.stderr)
        sys.exit(1)
    else:
        print(f"✅ PII & Secrets scan clean: {len(files_to_scan)} files scanned. No sensitive data found.")
        sys.exit(0)

if __name__ == "__main__":
    main()
