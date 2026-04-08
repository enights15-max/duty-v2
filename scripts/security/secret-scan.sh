#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

echo "[secret-scan] scanning tracked files for sensitive patterns..."

if git ls-files --error-unmatch .env >/dev/null 2>&1; then
  echo "[secret-scan] FAIL: '.env' is tracked by git. Remove it from index with:"
  echo "  git rm --cached .env"
  exit 1
fi

pattern='(sk_live_[A-Za-z0-9]{16,}|sk_test_[A-Za-z0-9]{16,}|pk_live_[A-Za-z0-9]{16,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[A-Za-z0-9-]{10,}|ghp_[A-Za-z0-9]{20,})'

matches="$(
  git grep -nEI "${pattern}" -- \
    ':!vendor/**' \
    ':!node_modules/**' \
    ':!storage/**' \
    ':!**/*.sql' \
    ':!public/assets/admin/file/invoices/**' \
    ':!public/assets/file/6999f02c63fd0.json' \
    ':!scripts/security/secret-scan.sh' \
    || true
)"

matches="$(echo "${matches}" | grep -v 'REPLACE_WITH_PRIVATE_KEY' || true)"

if [[ -n "${matches}" ]]; then
  echo "[secret-scan] FAIL: potential secrets found in tracked files:"
  echo "${matches}"
  exit 1
fi

echo "[secret-scan] OK"
