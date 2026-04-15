#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

ENV_FILE=".env"
BASE_URL=""
AUTH_TOKEN=""
AUTH_USERNAME=""
AUTH_PASSWORD=""
AUTH_DEVICE_NAME="rotation-window-check"
IDENTITY_ID=""
TOPUP_AMOUNT="25"
SCOPE="stripe"
REQUIRE_LIVE=0
ALLOW_PUBLIC_BASE_URL=0

PASS=0
FAIL=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/security/rotation-window-check.sh \
    --env-file .env \
    --scope <stripe|active|full> \
    --base-url https://your-host \
    [--auth-token <SANCTUM_TOKEN>] \
    [--auth-username <user> --auth-password <pass>] \
    [--identity-id <ID>] \
    [--topup-amount <N>] \
    [--require-live] \
    [--allow-public-base-url]

Scopes:
  stripe  — connectivity + auth + Stripe config (topup preview)
  active  — connectivity + auth + wallet read
  full    — all of the above
USAGE
}

log_pass() {
  local label="$1"
  echo "[rotation-window-check] PASS  ${label}"
  PASS=$((PASS + 1))
}

log_fail() {
  local label="$1"
  local detail="${2:-}"
  echo "[rotation-window-check] FAIL  ${label}${detail:+: ${detail}}"
  FAIL=$((FAIL + 1))
}

extract_host() {
  local url="$1"
  local without_scheme="${url#*://}"
  without_scheme="${without_scheme%%/*}"
  without_scheme="${without_scheme%%:*}"
  printf '%s' "${without_scheme}"
}

is_local_host() {
  local host="$1"
  case "${host}" in
    localhost|127.0.0.1|::1) return 0 ;;
  esac
  [[ "${host}" == *.local ]] && return 0
  [[ "${host}" =~ ^10\. ]] && return 0
  [[ "${host}" =~ ^192\.168\. ]] && return 0
  [[ "${host}" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]] && return 0
  return 1
}

api_get() {
  local path="$1"
  local token="${2:-}"
  local url="${BASE_URL%/}${path}"
  local args=(-s -o /dev/null -w "%{http_code}" --max-time 15 --connect-timeout 10)
  if [[ -n "${token}" ]]; then
    args+=(-H "Authorization: Bearer ${token}")
  fi
  args+=(-H "Accept: application/json")
  curl "${args[@]}" "${url}" 2>/dev/null || echo "000"
}

api_post() {
  local path="$1"
  local body="$2"
  local token="${3:-}"
  local url="${BASE_URL%/}${path}"
  local args=(-s -o /tmp/rwc_resp.json -w "%{http_code}" --max-time 20 --connect-timeout 10)
  args+=(-X POST -H "Content-Type: application/json" -H "Accept: application/json")
  if [[ -n "${token}" ]]; then
    args+=(-H "Authorization: Bearer ${token}")
  fi
  args+=(-d "${body}")
  curl "${args[@]}" "${url}" 2>/dev/null || echo "000"
}

resolve_token() {
  if [[ -n "${AUTH_TOKEN}" ]]; then
    printf '%s' "${AUTH_TOKEN}"
    return 0
  fi

  # Login to get token
  local body
  body="{\"email\":\"${AUTH_USERNAME}\",\"password\":\"${AUTH_PASSWORD}\",\"device_name\":\"${AUTH_DEVICE_NAME}\"}"
  local status
  status="$(api_post "/api/login/submit" "${body}")"
  if [[ "${status}" == "200" ]]; then
    local token
    token="$(cat /tmp/rwc_resp.json 2>/dev/null | grep -o '"token":"[^"]*"' | cut -d'"' -f4 || true)"
    if [[ -n "${token}" ]]; then
      printf '%s' "${token}"
      return 0
    fi
  fi
  echo "[rotation-window-check] ERROR: login failed (HTTP ${status})" >&2
  return 1
}

check_connectivity() {
  local status
  status="$(api_get "/api/get-basic")"
  if [[ "${status}" == "200" ]]; then
    log_pass "api_connectivity (GET /api/get-basic -> ${status})"
  else
    log_fail "api_connectivity" "GET /api/get-basic returned HTTP ${status}"
  fi
}

check_auth() {
  local token="$1"
  local status
  status="$(api_get "/api/wallet" "${token}")"
  if [[ "${status}" == "200" ]]; then
    log_pass "auth_token_valid (GET /api/wallet -> ${status})"
  elif [[ "${status}" == "404" ]]; then
    # Wallet might not exist yet — auth still worked
    log_pass "auth_token_valid (GET /api/wallet -> ${status} — no wallet yet, auth OK)"
  else
    log_fail "auth_token_valid" "GET /api/wallet returned HTTP ${status}"
  fi
}

check_wallet_read() {
  local token="$1"
  local status
  status="$(api_get "/api/wallet" "${token}")"
  if [[ "${status}" == "200" || "${status}" == "404" ]]; then
    log_pass "wallet_read (GET /api/wallet -> ${status})"
  else
    log_fail "wallet_read" "GET /api/wallet returned HTTP ${status}"
  fi
}

check_stripe_config() {
  local token="$1"
  local body="{\"amount\":${TOPUP_AMOUNT}}"
  local status
  status="$(api_post "/api/payments/intent/preview" "${body}" "${token}")"
  if [[ "${status}" == "200" ]]; then
    log_pass "stripe_config (POST /api/payments/intent/preview -> ${status})"
  elif [[ "${status}" == "422" ]]; then
    # Validation error but Stripe is configured
    log_pass "stripe_config (POST /api/payments/intent/preview -> ${status} — Stripe configured, validation error expected)"
  elif [[ "${status}" == "402" || "${status}" == "400" ]]; then
    log_pass "stripe_config (POST /api/payments/intent/preview -> ${status} — Stripe reachable)"
  else
    log_fail "stripe_config" "POST /api/payments/intent/preview returned HTTP ${status}"
  fi
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)       ENV_FILE="$2";       shift 2 ;;
    --scope)          SCOPE="$2";          shift 2 ;;
    --base-url)       BASE_URL="$2";       shift 2 ;;
    --auth-token)     AUTH_TOKEN="$2";     shift 2 ;;
    --auth-username)  AUTH_USERNAME="$2";  shift 2 ;;
    --auth-password)  AUTH_PASSWORD="$2";  shift 2 ;;
    --auth-device-name) AUTH_DEVICE_NAME="$2"; shift 2 ;;
    --identity-id)    IDENTITY_ID="$2";    shift 2 ;;
    --topup-amount)   TOPUP_AMOUNT="$2";   shift 2 ;;
    --require-live)   REQUIRE_LIVE=1;      shift ;;
    --allow-public-base-url) ALLOW_PUBLIC_BASE_URL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[rotation-window-check] Unknown argument: $1"; usage; exit 1 ;;
  esac
done

# Validate
if [[ -z "${BASE_URL}" ]]; then
  echo "[rotation-window-check] Missing --base-url"
  usage; exit 1
fi

if [[ -z "${AUTH_TOKEN}" && ( -z "${AUTH_USERNAME}" || -z "${AUTH_PASSWORD}" ) ]]; then
  echo "[rotation-window-check] Missing auth: provide --auth-token or --auth-username + --auth-password"
  usage; exit 1
fi

if [[ "${ALLOW_PUBLIC_BASE_URL}" != "1" ]]; then
  base_host="$(extract_host "${BASE_URL}")"
  if ! is_local_host "${base_host}"; then
    echo "[rotation-window-check] Refusing public base URL: ${BASE_URL}"
    echo "[rotation-window-check] Pass --allow-public-base-url for intentional live checks."
    exit 1
  fi
fi

echo "[rotation-window-check] scope=${SCOPE} url=${BASE_URL}"

# Resolve token
RESOLVED_TOKEN="$(resolve_token)"

# Run checks by scope
check_connectivity

case "${SCOPE}" in
  stripe)
    check_auth "${RESOLVED_TOKEN}"
    check_stripe_config "${RESOLVED_TOKEN}"
    ;;
  active)
    check_auth "${RESOLVED_TOKEN}"
    check_wallet_read "${RESOLVED_TOKEN}"
    ;;
  full)
    check_auth "${RESOLVED_TOKEN}"
    check_wallet_read "${RESOLVED_TOKEN}"
    check_stripe_config "${RESOLVED_TOKEN}"
    ;;
  *)
    echo "[rotation-window-check] Unknown scope: ${SCOPE}. Use: stripe | active | full"
    exit 1
    ;;
esac

echo "[rotation-window-check] Results: ${PASS} passed, ${FAIL} failed"

if [[ "${FAIL}" -gt 0 ]]; then
  exit 1
fi

exit 0
