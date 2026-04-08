#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

INPUT_FILE="${DUTY_MOBILE_RELEASE_INPUT_FILE:-${ROOT_DIR}/.mobile-release.env}"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/release/mobile-release-build-from-file.sh [--input-file <path>] [mobile-release-build options]

What it does:
  - Loads release build env vars from a local file
  - Delegates to scripts/release/mobile-release-build.sh

Default input file:
  - .mobile-release.env

Suggested flow:
  1) Copy .mobile-release.env.example to .mobile-release.env
  2) Fill the real values locally
  3) Run --check-only first
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
    echo "[mobile-release-build-from-file] Warning: ${target} permissions look open (${perms}). Recommended: chmod 600 ${target}" >&2
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
      echo "[mobile-release-build-from-file] Invalid line in ${target}: ${line}" >&2
      exit 1
    fi

    key="${line%%=*}"
    value="${line#*=}"
    key="$(printf '%s' "${key}" | tr -d '[:space:]')"

    if [[ -z "${key}" ]]; then
      echo "[mobile-release-build-from-file] Invalid key in ${target}: ${line}" >&2
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
    -h|--help)
      usage
      exit 0
      ;;
    *)
      forward_args+=("$1")
      shift
      ;;
  esac
done

if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "[mobile-release-build-from-file] Missing input file: ${INPUT_FILE}" >&2
  echo "[mobile-release-build-from-file] Copy .mobile-release.env.example to .mobile-release.env and fill it locally." >&2
  exit 1
fi

warn_if_permissions_too_open "${INPUT_FILE}"
load_env_file "${INPUT_FILE}"

build_args=()
if [[ -n "${DUTY_RELEASE_BUILD_NAME:-}" ]]; then
  build_args+=(--build-name "${DUTY_RELEASE_BUILD_NAME}")
fi
if [[ -n "${DUTY_RELEASE_BUILD_NUMBER:-}" ]]; then
  build_args+=(--build-number "${DUTY_RELEASE_BUILD_NUMBER}")
fi

./scripts/release/mobile-release-build.sh \
  "${build_args[@]}" \
  ${forward_args[@]+"${forward_args[@]}"}
