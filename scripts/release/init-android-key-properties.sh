#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

SOURCE_FILE="${ROOT_DIR}/flutter/cliente_v2/android/key.properties.example"
OUTPUT_FILE="${ROOT_DIR}/flutter/cliente_v2/android/key.properties"
FORCE=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/release/init-android-key-properties.sh [--output-file <path>] [--force]

What it does:
  - Copies flutter/cliente_v2/android/key.properties.example
  - Creates a local ignored key.properties file
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
      echo "[init-android-key-properties] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -f "${SOURCE_FILE}" ]]; then
  echo "[init-android-key-properties] Missing source template: ${SOURCE_FILE}" >&2
  exit 1
fi

if [[ -f "${OUTPUT_FILE}" && "${FORCE}" != "1" ]]; then
  echo "[init-android-key-properties] Refusing to overwrite existing file: ${OUTPUT_FILE}" >&2
  echo "[init-android-key-properties] Use --force if you really want to replace it." >&2
  exit 1
fi

cp "${SOURCE_FILE}" "${OUTPUT_FILE}"
chmod 600 "${OUTPUT_FILE}"

echo "[init-android-key-properties] Created ${OUTPUT_FILE}"
echo "[init-android-key-properties] Permissions set to 600"
