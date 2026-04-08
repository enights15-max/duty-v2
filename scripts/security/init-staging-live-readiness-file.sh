#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

SOURCE_FILE="${ROOT_DIR}/.staging-live-readiness.env.example"
OUTPUT_FILE="${ROOT_DIR}/.staging-live-readiness.env"
FORCE=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/security/init-staging-live-readiness-file.sh [--output-file <path>] [--force]

What it does:
  - Copies .staging-live-readiness.env.example into a local ignored file
  - Applies chmod 600 to the output file

Notes:
  - Refuses to overwrite an existing file unless --force is provided
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-file)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[init-staging-live-readiness-file] Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ ! -f "${SOURCE_FILE}" ]]; then
  echo "[init-staging-live-readiness-file] Missing source template: ${SOURCE_FILE}"
  exit 1
fi

if [[ -f "${OUTPUT_FILE}" && "${FORCE}" != "1" ]]; then
  echo "[init-staging-live-readiness-file] Refusing to overwrite existing file: ${OUTPUT_FILE}"
  echo "[init-staging-live-readiness-file] Use --force if you really want to replace it."
  exit 1
fi

mkdir -p "$(dirname "${OUTPUT_FILE}")"
cp "${SOURCE_FILE}" "${OUTPUT_FILE}"
chmod 600 "${OUTPUT_FILE}"

echo "[init-staging-live-readiness-file] Created ${OUTPUT_FILE}"
echo "[init-staging-live-readiness-file] Permissions set to 600"
