#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

BASE_URL="${DUTY_STAGING_BASE_URL:-}"
ENV_FILE="${DUTY_STAGING_ENV_FILE:-.env}"
AUTH_TOKEN="${DUTY_STAGING_AUTH_TOKEN:-}"
AUTH_USERNAME="${DUTY_STAGING_AUTH_USERNAME:-}"
AUTH_PASSWORD="${DUTY_STAGING_AUTH_PASSWORD:-}"
AUTH_DEVICE_NAME="${DUTY_STAGING_AUTH_DEVICE_NAME:-staging-readiness-window}"
IDENTITY_ID="${DUTY_STAGING_IDENTITY_ID:-}"
TOPUP_AMOUNT="${DUTY_STAGING_TOPUP_AMOUNT:-25}"
FINAL_SCOPE="${DUTY_STAGING_FINAL_SCOPE:-stripe}"
REPORT_DIR="${DUTY_STAGING_REPORT_DIR:-${ROOT_DIR}/storage/app/live-readiness/staging-dry-run-$(date +%Y%m%d_%H%M%S)}"
BOARD_OUTPUT="${DUTY_STAGING_BOARD_OUTPUT:-}"
BOARD_TITLE="${DUTY_STAGING_BOARD_TITLE:-Staging Live Go/No-Go Board}"
ALLOW_PUBLIC_BASE_URL="${DUTY_STAGING_ALLOW_PUBLIC_BASE_URL:-0}"

usage() {
  cat <<'USAGE'
Usage:
  DUTY_STAGING_BASE_URL="https://staging.example.com" \
  DUTY_STAGING_AUTH_TOKEN="TOKEN_REAL" \
  DUTY_STAGING_ALLOW_PUBLIC_BASE_URL=1 \
  ./scripts/security/staging-live-readiness-from-env.sh [--check-only]

Or with credentials:
  DUTY_STAGING_BASE_URL="https://staging.example.com" \
  DUTY_STAGING_AUTH_USERNAME="qa_customer_real" \
  DUTY_STAGING_AUTH_PASSWORD="PASSWORD_REAL" \
  DUTY_STAGING_ALLOW_PUBLIC_BASE_URL=1 \
  ./scripts/security/staging-live-readiness-from-env.sh [--check-only]

Supported env vars:
  DUTY_STAGING_BASE_URL
  DUTY_STAGING_ENV_FILE
  DUTY_STAGING_AUTH_TOKEN
  DUTY_STAGING_AUTH_USERNAME
  DUTY_STAGING_AUTH_PASSWORD
  DUTY_STAGING_AUTH_DEVICE_NAME
  DUTY_STAGING_IDENTITY_ID
  DUTY_STAGING_TOPUP_AMOUNT
  DUTY_STAGING_FINAL_SCOPE
  DUTY_STAGING_REPORT_DIR
  DUTY_STAGING_BOARD_OUTPUT
  DUTY_STAGING_BOARD_TITLE
  DUTY_STAGING_ALLOW_PUBLIC_BASE_URL
USAGE
}

looks_like_placeholder() {
  local value="$1"

  case "${value}" in
    ""|https://staging.example.com|http://staging.example.com|TOKEN_REAL|PASSWORD_REAL|qa_customer_real)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

check_only=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-only)
      check_only=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[staging-live-readiness-from-env] Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${BASE_URL}" ]]; then
  echo "[staging-live-readiness-from-env] Missing DUTY_STAGING_BASE_URL."
  usage
  exit 1
fi

if looks_like_placeholder "${BASE_URL}"; then
  echo "[staging-live-readiness-from-env] DUTY_STAGING_BASE_URL still looks like a placeholder. Set the real staging URL."
  exit 1
fi

if [[ -z "${AUTH_TOKEN}" && ( -z "${AUTH_USERNAME}" || -z "${AUTH_PASSWORD}" ) ]]; then
  echo "[staging-live-readiness-from-env] Missing auth env. Set DUTY_STAGING_AUTH_TOKEN or DUTY_STAGING_AUTH_USERNAME + DUTY_STAGING_AUTH_PASSWORD."
  usage
  exit 1
fi

if [[ -n "${AUTH_TOKEN}" ]] && looks_like_placeholder "${AUTH_TOKEN}"; then
  echo "[staging-live-readiness-from-env] DUTY_STAGING_AUTH_TOKEN still looks like a placeholder. Set a real staging token."
  exit 1
fi

if [[ -n "${AUTH_USERNAME}" ]] && looks_like_placeholder "${AUTH_USERNAME}"; then
  echo "[staging-live-readiness-from-env] DUTY_STAGING_AUTH_USERNAME still looks like a placeholder. Set a real staging username."
  exit 1
fi

if [[ -n "${AUTH_PASSWORD}" ]] && looks_like_placeholder "${AUTH_PASSWORD}"; then
  echo "[staging-live-readiness-from-env] DUTY_STAGING_AUTH_PASSWORD still looks like a placeholder. Set a real staging password."
  exit 1
fi

if [[ -z "${BOARD_OUTPUT}" ]]; then
  BOARD_OUTPUT="${REPORT_DIR}/go-no-go-board.md"
fi

extra_args=()
if [[ "${ALLOW_PUBLIC_BASE_URL}" == "1" ]]; then
  extra_args+=(--allow-public-base-url)
fi
if [[ -n "${AUTH_TOKEN}" ]]; then
  extra_args+=(--auth-token "${AUTH_TOKEN}")
else
  extra_args+=(--auth-username "${AUTH_USERNAME}" --auth-password "${AUTH_PASSWORD}")
fi
if [[ -n "${IDENTITY_ID}" ]]; then
  extra_args+=(--identity-id "${IDENTITY_ID}")
fi
if [[ "${check_only}" == "1" ]]; then
  extra_args+=(--check-only)
fi

./scripts/security/staging-live-readiness-dry-run.sh \
  --env-file "${ENV_FILE}" \
  --base-url "${BASE_URL}" \
  --auth-device-name "${AUTH_DEVICE_NAME}" \
  --topup-amount "${TOPUP_AMOUNT}" \
  --final-scope "${FINAL_SCOPE}" \
  --report-dir "${REPORT_DIR}" \
  --board-output "${BOARD_OUTPUT}" \
  --board-title "${BOARD_TITLE}" \
  ${extra_args[@]+"${extra_args[@]}"}
