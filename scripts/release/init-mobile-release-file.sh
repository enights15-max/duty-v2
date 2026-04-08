#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

SOURCE_FILE="${ROOT_DIR}/.mobile-release.env.example"
OUTPUT_FILE="${ROOT_DIR}/.mobile-release.env"
FORCE=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/release/init-mobile-release-file.sh [--output-file <path>] [--force]

What it does:
  - Copies .mobile-release.env.example into a local ignored file
  - Sets permissions to 600
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
      echo "[init-mobile-release-file] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -f "${SOURCE_FILE}" ]]; then
  echo "[init-mobile-release-file] Missing source template: ${SOURCE_FILE}" >&2
  exit 1
fi

if [[ -f "${OUTPUT_FILE}" && "${FORCE}" != "1" ]]; then
  echo "[init-mobile-release-file] Refusing to overwrite existing file: ${OUTPUT_FILE}" >&2
  echo "[init-mobile-release-file] Use --force if you really want to replace it." >&2
  exit 1
fi

cp "${SOURCE_FILE}" "${OUTPUT_FILE}"
chmod 600 "${OUTPUT_FILE}"

echo "[init-mobile-release-file] Created ${OUTPUT_FILE}"
echo "[init-mobile-release-file] Permissions set to 600"
