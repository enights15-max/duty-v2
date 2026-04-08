#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

ENV_FILE=".env"
BASE_URL="${DUTY_APP_BASE_URL:-}"
AUTH_TOKEN="${DUTY_AUTH_TOKEN:-}"
AUTH_USERNAME="${DUTY_AUTH_USERNAME:-}"
AUTH_PASSWORD="${DUTY_AUTH_PASSWORD:-}"
AUTH_DEVICE_NAME="${DUTY_AUTH_DEVICE_NAME:-final-live-readiness}"
IDENTITY_ID="${DUTY_IDENTITY_ID:-}"
TOPUP_AMOUNT="${DUTY_TEST_TOPUP_AMOUNT:-25}"
FINAL_SCOPE="${DUTY_FINAL_SCOPE:-stripe}"
ALLOW_PUBLIC_BASE_URL="${DUTY_ALLOW_PUBLIC_BASE_URL:-0}"
REPORT_DIR="${DUTY_LIVE_READINESS_REPORT_DIR:-${ROOT_DIR}/storage/app/live-readiness/$(date +%Y%m%d_%H%M%S)}"
STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
AUTH_MODE="token"
STRIPE_SCOPE_STATUS="not_run"
FINAL_SCOPE_STATUS="not_run"
STRIPE_SCOPE_LOG=""
FINAL_SCOPE_LOG=""
GENERATE_REPORT_ON_EXIT=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/security/final-live-readiness.sh \
    --env-file .env \
    --base-url https://your-host \
    [--auth-token <SANCTUM_TOKEN> | --auth-username <user> --auth-password <pass>] \
    [--final-scope <stripe|active|full>] \
    [--report-dir <path>] \
    [--allow-public-base-url] \
    [--auth-device-name <name>] \
    [--identity-id <ID>] \
    [--topup-amount <N>]

What it does:
  1) Stripe-scoped live readiness check.
  2) Final live readiness check (scope configurable, Stripe by default).
  3) Writes a readiness evidence bundle with logs and GO/NO-GO summary.

Notes:
  - Uses rotation-window-check in --require-live mode.
  - Supports auto-login with --auth-username/--auth-password when --auth-token is not provided.
  - Public domains are blocked by default; use --allow-public-base-url for intentional live cutovers.
  - Intended for final live/staging cutover windows.
USAGE
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
    localhost|127.0.0.1|::1)
      return 0
      ;;
  esac

  if [[ "${host}" == *.local ]]; then
    return 0
  fi

  if [[ "${host}" =~ ^10\. ]]; then
    return 0
  fi

  if [[ "${host}" =~ ^192\.168\. ]]; then
    return 0
  fi

  if [[ "${host}" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
    return 0
  fi

  return 1
}

status_label() {
  local value="$1"
  case "${value}" in
    passed) printf 'PASSED' ;;
    failed) printf 'FAILED' ;;
    *) printf '%s' "${value}" ;;
  esac
}

generate_report() {
  if [[ "${GENERATE_REPORT_ON_EXIT}" != "1" ]]; then
    return 0
  fi

  local exit_code="${1:-0}"
  local finished_at
  finished_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local automated_recommendation="NO-GO"

  if [[ "${STRIPE_SCOPE_STATUS}" == "passed" && "${FINAL_SCOPE_STATUS}" == "passed" && "${exit_code}" == "0" ]]; then
    automated_recommendation="GO"
  fi

  mkdir -p "${REPORT_DIR}"

  cat > "${REPORT_DIR}/README.md" <<EOF
# Final Live Readiness Report

- Started at (UTC): ${STARTED_AT}
- Finished at (UTC): ${finished_at}
- Base URL: ${BASE_URL}
- Env file: ${ENV_FILE}
- Final scope: ${FINAL_SCOPE}
- Auth mode: ${AUTH_MODE}
- Stripe scope status: $(status_label "${STRIPE_SCOPE_STATUS}")
- Final scope status: $(status_label "${FINAL_SCOPE_STATUS}")
- Automated recommendation: ${automated_recommendation}
- Exit code: ${exit_code}

## Automated checks

1. Stripe scope
   - log: ${STRIPE_SCOPE_LOG:-not generated}
2. Final scope
   - log: ${FINAL_SCOPE_LOG:-not generated}
3. Manual evidence template
   - file: ${REPORT_DIR}/manual-evidence.md

## Manual gates still required

- [ ] Confirmar secretos reales de Stripe/Firebase cargados e invalidados los anteriores.
- [ ] Confirmar base URL final y ventana operativa aprobada.
- [ ] Ejecutar QA manual live minima:
  - [ ] login/session
  - [ ] checkout mixto real
  - [ ] wallet + topup real
  - [ ] reservas y abonos
  - [ ] marketplace
  - [ ] scanner
  - [ ] account center
  - [ ] create/edit event profesional
- [ ] Guardar evidencia humana adicional:
  - [ ] capturas o notas
  - [ ] responsable de la rotacion
  - [ ] decision final go/no-go

## Referencias

- docs/security-rotation-checklist-2026-03-09.md
- docs/sprint-1-live-cutover-checklist-2026-03-18.md
- docs/qa-manual-lanzamiento-local-2026-03-12.md
EOF

  cat > "${REPORT_DIR}/manual-evidence.md" <<EOF
# Manual Live Evidence

- Window date:
- Environment:
- Base URL: ${BASE_URL}
- Env file: ${ENV_FILE}
- Operator:
- Reviewer:
- Decision owner:

## Secrets and Rotation

- [ ] Stripe secrets confirmed as real and active
- [ ] Firebase credentials confirmed as real and active
- [ ] Previous secrets invalidated
- [ ] Secret manager / env file reviewed
- Notes:

## Manual QA Results

### Login and Session
- [ ] Pass
- Evidence:
- Notes:

### Mixed Checkout
- [ ] Pass
- Evidence:
- Notes:

### Wallet and Topup
- [ ] Pass
- Evidence:
- Notes:

### Reservations and Installments
- [ ] Pass
- Evidence:
- Notes:

### Marketplace
- [ ] Pass
- Evidence:
- Notes:

### Scanner
- [ ] Pass
- Evidence:
- Notes:

### Account Center
- [ ] Pass
- Evidence:
- Notes:

### Professional Event Authoring
- [ ] Pass
- Evidence:
- Notes:

## Findings

| ID | Severity | Flow | Result | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

## Final Decision

- Automated recommendation: ${automated_recommendation}
- Manual decision: GO / NO-GO
- Approved by:
- Approval timestamp:
- Follow-up actions:
EOF

  cat > "${REPORT_DIR}/summary.json" <<EOF
{
  "started_at": "${STARTED_AT}",
  "finished_at": "${finished_at}",
  "report_dir": "$(printf '%s' "${REPORT_DIR}" | sed 's/"/\\"/g')",
  "manual_evidence_path": "$(printf '%s' "${REPORT_DIR}/manual-evidence.md" | sed 's/"/\\"/g')",
  "base_url": "$(printf '%s' "${BASE_URL}" | sed 's/"/\\"/g')",
  "env_file": "$(printf '%s' "${ENV_FILE}" | sed 's/"/\\"/g')",
  "final_scope": "${FINAL_SCOPE}",
  "auth_mode": "${AUTH_MODE}",
  "stripe_scope_status": "${STRIPE_SCOPE_STATUS}",
  "final_scope_status": "${FINAL_SCOPE_STATUS}",
  "automated_recommendation": "${automated_recommendation}",
  "exit_code": ${exit_code}
}
EOF
}

run_window_check() {
  local label="$1"
  local scope="$2"
  local log_file="$3"

  mkdir -p "$(dirname "${log_file}")"
  set +e
  ./scripts/security/rotation-window-check.sh \
    --env-file "${ENV_FILE}" \
    --scope "${scope}" \
    --base-url "${BASE_URL}" \
    ${AUTH_TOKEN:+--auth-token "${AUTH_TOKEN}"} \
    ${IDENTITY_ID:+--identity-id "${IDENTITY_ID}"} \
    --topup-amount "${TOPUP_AMOUNT}" \
    ${window_extra_args[@]+"${window_extra_args[@]}"} \
    --require-live 2>&1 | tee "${log_file}"
  local status=${PIPESTATUS[0]}
  set -e

  if [[ "${label}" == "stripe" ]]; then
    STRIPE_SCOPE_LOG="${log_file}"
    STRIPE_SCOPE_STATUS=$([[ ${status} -eq 0 ]] && echo "passed" || echo "failed")
  else
    FINAL_SCOPE_LOG="${log_file}"
    FINAL_SCOPE_STATUS=$([[ ${status} -eq 0 ]] && echo "passed" || echo "failed")
  fi

  return ${status}
}

on_exit() {
  local exit_code=$?
  generate_report "${exit_code}"
}

trap on_exit EXIT

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
    --final-scope)
      FINAL_SCOPE="$2"
      shift 2
      ;;
    --report-dir)
      REPORT_DIR="$2"
      shift 2
      ;;
    --allow-public-base-url)
      ALLOW_PUBLIC_BASE_URL=1
      shift
      ;;
    --identity-id)
      IDENTITY_ID="$2"
      shift 2
      ;;
    --topup-amount)
      TOPUP_AMOUNT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[final-live-readiness] Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${BASE_URL}" ]]; then
  echo "[final-live-readiness] Missing required --base-url."
  usage
  exit 1
fi

if [[ -n "${AUTH_USERNAME}" && -z "${AUTH_PASSWORD}" ]] || [[ -z "${AUTH_USERNAME}" && -n "${AUTH_PASSWORD}" ]]; then
  echo "[final-live-readiness] Provide both --auth-username and --auth-password (or neither)."
  exit 1
fi

if [[ -z "${AUTH_TOKEN}" && ( -z "${AUTH_USERNAME}" || -z "${AUTH_PASSWORD}" ) ]]; then
  echo "[final-live-readiness] Missing auth. Provide --auth-token OR (--auth-username and --auth-password)."
  usage
  exit 1
fi

if [[ -n "${AUTH_USERNAME}" && -n "${AUTH_PASSWORD}" ]]; then
  AUTH_MODE="credentials"
fi

if [[ "${FINAL_SCOPE}" != "full" && "${FINAL_SCOPE}" != "active" && "${FINAL_SCOPE}" != "stripe" ]]; then
  echo "[final-live-readiness] Invalid --final-scope '${FINAL_SCOPE}'. Use: stripe | active | full"
  exit 1
fi

base_host="$(extract_host "${BASE_URL}")"
if [[ -z "${base_host}" ]]; then
  echo "[final-live-readiness] Invalid --base-url value: ${BASE_URL}"
  exit 1
fi

if [[ "${ALLOW_PUBLIC_BASE_URL}" != "1" ]] && ! is_local_host "${base_host}"; then
  echo "[final-live-readiness] Refusing public base URL by default: ${BASE_URL}"
  echo "[final-live-readiness] Use localhost/internal URL, or pass --allow-public-base-url for explicit live cutover."
  exit 1
fi

window_extra_args=()
if [[ "${ALLOW_PUBLIC_BASE_URL}" == "1" ]]; then
  window_extra_args+=(--allow-public-base-url)
fi
if [[ -n "${AUTH_USERNAME}" ]]; then
  window_extra_args+=(--auth-username "${AUTH_USERNAME}" --auth-password "${AUTH_PASSWORD}" --auth-device-name "${AUTH_DEVICE_NAME}")
fi

mkdir -p "${REPORT_DIR}"
GENERATE_REPORT_ON_EXIT=1

echo "[final-live-readiness] Step 1/2: Stripe scope"
run_window_check "stripe" "stripe" "${REPORT_DIR}/stripe-scope.log"

echo "[final-live-readiness] Step 2/2: ${FINAL_SCOPE} scope"
run_window_check "final" "${FINAL_SCOPE}" "${REPORT_DIR}/${FINAL_SCOPE}-scope.log"

echo "[final-live-readiness] OK"
echo "[final-live-readiness] Evidence bundle: ${REPORT_DIR}"
