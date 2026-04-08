#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

INPUT_FILE="${DUTY_STAGING_INPUT_FILE:-${ROOT_DIR}/.staging-live-readiness.env}"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/security/staging-live-readiness-from-file.sh [--input-file <path>] [--check-only]

What it does:
  - Loads staging readiness env vars from a local file
  - Delegates to staging-live-readiness-from-env.sh

Defaults:
  - --input-file: .staging-live-readiness.env

Expected workflow:
  1) Copy .staging-live-readiness.env.example to .staging-live-readiness.env
  2) Fill in the real staging values locally
  3) Run this script with --check-only first
USAGE
}

detect_octal_perms() {
  local target="$1"

  if stat -f '%OLp' "${target}" >/dev/null 2>&1; then
    stat -f '%OLp' "${target}"
    return 0
  fi

  if stat -c '%a' "${target}" >/dev/null 2>&1; then
    stat -c '%a' "${target}"
    return 0
  fi

  return 1
}

warn_if_permissions_too_open() {
  local target="$1"
  local perms=""

  perms="$(detect_octal_perms "${target}" || true)"
  if [[ -z "${perms}" ]]; then
    return 0
  fi

  perms="$(printf '%s' "${perms}" | sed 's/^0*//')"
  perms="${perms:-0}"

  local owner=0
  local group=0
  local other=0

  if [[ ${#perms} -ge 3 ]]; then
    owner="${perms: -3:1}"
    group="${perms: -2:1}"
    other="${perms: -1:1}"
  elif [[ ${#perms} -eq 2 ]]; then
    owner="${perms:0:1}"
    group="${perms:1:1}"
  elif [[ ${#perms} -eq 1 ]]; then
    owner="${perms:0:1}"
  fi

  if [[ "${group}" != "0" || "${other}" != "0" ]]; then
    echo "[staging-live-readiness-from-file] Warning: ${target} permissions look open (${perms}). Recommended: chmod 600 ${target}" >&2
  fi
}

load_env_file() {
  local target="$1"
  local line=""
  local key=""
  local value=""

  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%$'\r'}"

    if [[ -z "${line//[[:space:]]/}" ]]; then
      continue
    fi

    if [[ "${line}" =~ ^[[:space:]]*# ]]; then
      continue
    fi

    if [[ "${line}" != *"="* ]]; then
      echo "[staging-live-readiness-from-file] Invalid line in ${target}: ${line}" >&2
      exit 1
    fi

    key="${line%%=*}"
    value="${line#*=}"
    key="$(printf '%s' "${key}" | tr -d '[:space:]')"

    if [[ -z "${key}" ]]; then
      echo "[staging-live-readiness-from-file] Invalid key in ${target}: ${line}" >&2
      exit 1
    fi

    export "${key}=${value}"
  done < "${target}"
}

forward_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input-file)
      INPUT_FILE="$2"
      shift 2
      ;;
    --check-only)
      forward_args+=(--check-only)
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[staging-live-readiness-from-file] Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "[staging-live-readiness-from-file] Missing input file: ${INPUT_FILE}"
  echo "[staging-live-readiness-from-file] Copy .staging-live-readiness.env.example to .staging-live-readiness.env and fill it locally."
  exit 1
fi

warn_if_permissions_too_open "${INPUT_FILE}"

load_env_file "${INPUT_FILE}"

./scripts/security/staging-live-readiness-from-env.sh ${forward_args[@]+"${forward_args[@]}"}
