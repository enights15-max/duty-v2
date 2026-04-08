#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

ENV_FILE=".env"
BASE_URL="${DUTY_APP_BASE_URL:-}"
AUTH_TOKEN="${DUTY_AUTH_TOKEN:-}"
AUTH_USERNAME="${DUTY_AUTH_USERNAME:-}"
AUTH_PASSWORD="${DUTY_AUTH_PASSWORD:-}"
AUTH_DEVICE_NAME="${DUTY_AUTH_DEVICE_NAME:-staging-live-readiness-dry-run}"
IDENTITY_ID="${DUTY_IDENTITY_ID:-}"
TOPUP_AMOUNT="${DUTY_TEST_TOPUP_AMOUNT:-25}"
FINAL_SCOPE="${DUTY_FINAL_SCOPE:-stripe}"
ALLOW_PUBLIC_BASE_URL="${DUTY_ALLOW_PUBLIC_BASE_URL:-0}"
REPORT_DIR="${DUTY_LIVE_READINESS_REPORT_DIR:-${ROOT_DIR}/storage/app/live-readiness/staging-dry-run-$(date +%Y%m%d_%H%M%S)}"
BOARD_OUTPUT=""
BOARD_TITLE="Staging Live Go/No-Go Board"
CHECK_ONLY=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/security/staging-live-readiness-dry-run.sh \
    --env-file .env \
    --base-url https://staging.example.com \
    [--auth-token <SANCTUM_TOKEN> | --auth-username <user> --auth-password <pass>] \
    [--identity-id <ID>] \
    [--topup-amount <N>] \
    [--final-scope <stripe|active|full>] \
    [--report-dir <path>] \
    [--board-output <path>] \
    [--board-title <text>] \
    [--auth-device-name <name>] \
    [--check-only] \
    [--allow-public-base-url]

What it does:
  1) Runs final-live-readiness.sh against staging or a pre-live environment.
  2) Generates a go/no-go board from the resulting bundle.
  3) Prints the artifact paths to use in QA/ops review.
  4) With --check-only, validates inputs and exits before remote calls.

Defaults:
  - --report-dir: storage/app/live-readiness/staging-dry-run-YYYYMMDD_HHMMSS
  - --board-output: <report-dir>/go-no-go-board.md
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --base-url)
      BASE_URL="$2"
      shift 2
      ;;
    --auth-token)
      AUTH_TOKEN="$2"
      shift 2
      ;;
    --auth-username)
      AUTH_USERNAME="$2"
      shift 2
      ;;
    --auth-password)
      AUTH_PASSWORD="$2"
      shift 2
      ;;
    --auth-device-name)
      AUTH_DEVICE_NAME="$2"
      shift 2
      ;;
    --identity-id)
      IDENTITY_ID="$2"
      shift 2
      ;;
    --topup-amount)
      TOPUP_AMOUNT="$2"
      shift 2
      ;;
    --final-scope)
      FINAL_SCOPE="$2"
      shift 2
      ;;
    --report-dir)
      REPORT_DIR="$2"
      shift 2
      ;;
    --board-output)
      BOARD_OUTPUT="$2"
      shift 2
      ;;
    --board-title)
      BOARD_TITLE="$2"
      shift 2
      ;;
    --check-only)
      CHECK_ONLY=1
      shift
      ;;
    --allow-public-base-url)
      ALLOW_PUBLIC_BASE_URL=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[staging-live-readiness-dry-run] Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${BASE_URL}" ]]; then
  echo "[staging-live-readiness-dry-run] Missing required --base-url."
  usage
  exit 1
fi

if [[ -z "${AUTH_TOKEN}" && ( -z "${AUTH_USERNAME}" || -z "${AUTH_PASSWORD}" ) ]]; then
  echo "[staging-live-readiness-dry-run] Missing auth. Provide --auth-token OR (--auth-username and --auth-password)."
  usage
  exit 1
fi

if [[ -n "${AUTH_USERNAME}" && -z "${AUTH_PASSWORD}" ]] || [[ -z "${AUTH_USERNAME}" && -n "${AUTH_PASSWORD}" ]]; then
  echo "[staging-live-readiness-dry-run] Provide both --auth-username and --auth-password (or neither)."
  exit 1
fi

if [[ -z "${BOARD_OUTPUT}" ]]; then
  BOARD_OUTPUT="${REPORT_DIR}/go-no-go-board.md"
fi

readiness_extra_args=()
if [[ "${ALLOW_PUBLIC_BASE_URL}" == "1" ]]; then
  readiness_extra_args+=(--allow-public-base-url)
fi
if [[ -n "${AUTH_USERNAME}" ]]; then
  readiness_extra_args+=(--auth-username "${AUTH_USERNAME}" --auth-password "${AUTH_PASSWORD}")
fi

auth_mode="token"
if [[ -n "${AUTH_USERNAME}" ]]; then
  auth_mode="credentials"
fi

echo "[staging-live-readiness-dry-run] Input summary"
echo "  env file: ${ENV_FILE}"
echo "  base url: ${BASE_URL}"
echo "  auth mode: ${auth_mode}"
echo "  identity id: ${IDENTITY_ID:-not provided}"
echo "  topup amount: ${TOPUP_AMOUNT}"
echo "  final scope: ${FINAL_SCOPE}"
echo "  report dir: ${REPORT_DIR}"
echo "  board output: ${BOARD_OUTPUT}"
echo "  allow public base url: $([[ "${ALLOW_PUBLIC_BASE_URL}" == "1" ]] && printf 'yes' || printf 'no')"

if [[ "${CHECK_ONLY}" == "1" ]]; then
  echo "[staging-live-readiness-dry-run] CHECK-ONLY OK"
  exit 0
fi

mkdir -p "${REPORT_DIR}"

echo "[staging-live-readiness-dry-run] Running final live readiness bundle..."
./scripts/security/final-live-readiness.sh \
  --env-file "${ENV_FILE}" \
  --base-url "${BASE_URL}" \
  ${AUTH_TOKEN:+--auth-token "${AUTH_TOKEN}"} \
  ${IDENTITY_ID:+--identity-id "${IDENTITY_ID}"} \
  --topup-amount "${TOPUP_AMOUNT}" \
  --final-scope "${FINAL_SCOPE}" \
  --report-dir "${REPORT_DIR}" \
  --auth-device-name "${AUTH_DEVICE_NAME}" \
  ${readiness_extra_args[@]+"${readiness_extra_args[@]}"}

echo "[staging-live-readiness-dry-run] Rendering go/no-go board..."
./scripts/security/render-live-go-no-go-board.sh \
  --report-dir "${REPORT_DIR}" \
  --output "${BOARD_OUTPUT}" \
  --title "${BOARD_TITLE}"

echo "[staging-live-readiness-dry-run] Done"
echo "[staging-live-readiness-dry-run] Report dir: ${REPORT_DIR}"
echo "[staging-live-readiness-dry-run] Board: ${BOARD_OUTPUT}"
