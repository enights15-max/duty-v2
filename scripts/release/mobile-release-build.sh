#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FLUTTER_DIR="${ROOT_DIR}/flutter/cliente_v2"

PLATFORM="all"
ANDROID_FORMAT="aab"
IOS_NO_CODESIGN=1
IOS_EXPORT_OPTIONS_PLIST=""
BUILD_NAME=""
BUILD_NUMBER=""
CHECK_ONLY=0
ALLOW_DEBUG_SIGNING=0

API_BASE_URL="${DUTY_RELEASE_API_BASE_URL:-}"
PUBLIC_BASE_URL="${DUTY_RELEASE_PUBLIC_BASE_URL:-}"
GOOGLE_MAPS_API_KEY="${DUTY_RELEASE_GOOGLE_MAPS_API_KEY:-}"

usage() {
  cat <<'USAGE'
Usage:
  DUTY_RELEASE_API_BASE_URL="https://api.example.com/v2/api" \
  DUTY_RELEASE_PUBLIC_BASE_URL="https://duty.do" \
  DUTY_RELEASE_GOOGLE_MAPS_API_KEY="..." \
  ./scripts/release/mobile-release-build.sh [options]

Options:
  --platform <android|ios|all>     Build target. Default: all
  --android-format <aab|apk>       Android artifact. Default: aab
  --ios-no-codesign                Build iOS without codesign. Default behavior
  --ios-export-options-plist <p>   ExportOptions.plist path for signed IPA export
  --build-name <name>              Override Flutter build name
  --build-number <number>          Override Flutter build number
  --allow-debug-signing            Allow Android release builds with debug signing
  --check-only                     Validate configuration and print commands only
  -h, --help                       Show this help

Required env vars:
  DUTY_RELEASE_API_BASE_URL

Optional env vars:
  DUTY_RELEASE_PUBLIC_BASE_URL
  DUTY_RELEASE_GOOGLE_MAPS_API_KEY

Examples:
  DUTY_RELEASE_API_BASE_URL="https://api.duty.do/v2/api" \
  DUTY_RELEASE_PUBLIC_BASE_URL="https://v2.duty.do" \
  ./scripts/release/mobile-release-build.sh --platform android --check-only

  DUTY_RELEASE_API_BASE_URL="https://api.duty.do/v2/api" \
  DUTY_RELEASE_PUBLIC_BASE_URL="https://v2.duty.do" \
  ./scripts/release/mobile-release-build.sh --platform ios --build-name 1.0.0 --build-number 1
USAGE
}

looks_like_placeholder() {
  local value="$1"

  case "${value}" in
    ""|https://example.com|https://api.example.com/v2/api|https://staging.example.com|http://localhost*|TOKEN_REAL|CHANGE_ME|/absolute/path/to/upload-keystore.jks)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_local_or_private_url() {
  local url="$1"
  local host=""

  host="$(python3 - <<'PY' "${url}"
import sys
from urllib.parse import urlparse
try:
    print((urlparse(sys.argv[1]).hostname or "").lower())
except Exception:
    print("")
PY
)"

  if [[ -z "${host}" ]]; then
    return 0
  fi

  case "${host}" in
    localhost|127.0.0.1|::1)
      return 0
      ;;
  esac

  if [[ "${host}" == 10.* || "${host}" == 192.168.* || "${host}" == 172.16.* || "${host}" == 172.17.* || "${host}" == 172.18.* || "${host}" == 172.19.* || "${host}" == 172.2* || "${host}" == 172.30.* || "${host}" == 172.31.* ]]; then
    return 0
  fi

  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --android-format)
      ANDROID_FORMAT="$2"
      shift 2
      ;;
    --ios-no-codesign)
      IOS_NO_CODESIGN=1
      shift
      ;;
    --ios-export-options-plist)
      IOS_EXPORT_OPTIONS_PLIST="$2"
      IOS_NO_CODESIGN=0
      shift 2
      ;;
    --build-name)
      BUILD_NAME="$2"
      shift 2
      ;;
    --build-number)
      BUILD_NUMBER="$2"
      shift 2
      ;;
    --allow-debug-signing)
      ALLOW_DEBUG_SIGNING=1
      shift
      ;;
    --check-only)
      CHECK_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[mobile-release-build] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "${PLATFORM}" != "android" && "${PLATFORM}" != "ios" && "${PLATFORM}" != "all" ]]; then
  echo "[mobile-release-build] Invalid --platform: ${PLATFORM}" >&2
  exit 1
fi

if [[ "${ANDROID_FORMAT}" != "aab" && "${ANDROID_FORMAT}" != "apk" ]]; then
  echo "[mobile-release-build] Invalid --android-format: ${ANDROID_FORMAT}" >&2
  exit 1
fi

if looks_like_placeholder "${API_BASE_URL}"; then
  echo "[mobile-release-build] DUTY_RELEASE_API_BASE_URL is missing or still looks like a placeholder." >&2
  exit 1
fi

if is_local_or_private_url "${API_BASE_URL}"; then
  echo "[mobile-release-build] DUTY_RELEASE_API_BASE_URL points to a local/private host. Use the real release API URL." >&2
  exit 1
fi

if [[ -n "${PUBLIC_BASE_URL}" ]]; then
  if looks_like_placeholder "${PUBLIC_BASE_URL}"; then
    echo "[mobile-release-build] DUTY_RELEASE_PUBLIC_BASE_URL still looks like a placeholder." >&2
    exit 1
  fi

  if is_local_or_private_url "${PUBLIC_BASE_URL}"; then
    echo "[mobile-release-build] DUTY_RELEASE_PUBLIC_BASE_URL points to a local/private host. Use the real public URL." >&2
    exit 1
  fi
fi

if [[ -n "${IOS_EXPORT_OPTIONS_PLIST}" && ! -f "${IOS_EXPORT_OPTIONS_PLIST}" ]]; then
  echo "[mobile-release-build] Missing ExportOptions.plist: ${IOS_EXPORT_OPTIONS_PLIST}" >&2
  exit 1
fi

flutter_args=()
flutter_args+=(--dart-define="API_BASE_URL=${API_BASE_URL}")
if [[ -n "${PUBLIC_BASE_URL}" ]]; then
  flutter_args+=(--dart-define="PUBLIC_BASE_URL=${PUBLIC_BASE_URL}")
fi
if [[ -n "${GOOGLE_MAPS_API_KEY}" ]]; then
  flutter_args+=(--dart-define="GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY}")
fi
if [[ -n "${BUILD_NAME}" ]]; then
  flutter_args+=(--build-name="${BUILD_NAME}")
fi
if [[ -n "${BUILD_NUMBER}" ]]; then
  flutter_args+=(--build-number="${BUILD_NUMBER}")
fi

android_gradle="${FLUTTER_DIR}/android/app/build.gradle.kts"
android_key_properties="${FLUTTER_DIR}/android/key.properties"
android_has_release_key_file=0
android_keystore_path=""
android_store_password=""
android_key_alias=""
android_key_password=""

if [[ -f "${android_key_properties}" ]]; then
  android_keystore_path="$(awk -F= '/^storeFile=/{sub(/^[^=]*=/,""); print; exit}' "${android_key_properties}")"
  android_store_password="$(awk -F= '/^storePassword=/{sub(/^[^=]*=/,""); print; exit}' "${android_key_properties}")"
  android_key_alias="$(awk -F= '/^keyAlias=/{sub(/^[^=]*=/,""); print; exit}' "${android_key_properties}")"
  android_key_password="$(awk -F= '/^keyPassword=/{sub(/^[^=]*=/,""); print; exit}' "${android_key_properties}")"

  if ! looks_like_placeholder "${android_keystore_path}" \
    && ! looks_like_placeholder "${android_store_password}" \
    && ! looks_like_placeholder "${android_key_alias}" \
    && ! looks_like_placeholder "${android_key_password}" \
    && [[ -f "${android_keystore_path}" ]]; then
    android_has_release_key_file=1
  fi
fi

echo "[mobile-release-build] Input summary"
echo "  platform: ${PLATFORM}"
echo "  android format: ${ANDROID_FORMAT}"
echo "  api base url: ${API_BASE_URL}"
echo "  public base url: ${PUBLIC_BASE_URL:-<derived from api base>}"
echo "  build name: ${BUILD_NAME:-<pubspec default>}"
echo "  build number: ${BUILD_NUMBER:-<pubspec default>}"
echo "  ios codesign: $([[ "${IOS_NO_CODESIGN}" == "1" ]] && printf 'disabled' || printf 'enabled')"

if [[ "${android_has_release_key_file}" != "1" && ( "${PLATFORM}" == "android" || "${PLATFORM}" == "all" ) ]]; then
  echo "[mobile-release-build] Warning: Android release signing file is missing or incomplete: ${android_key_properties}" >&2
  if [[ -f "${android_key_properties}" ]]; then
    if looks_like_placeholder "${android_keystore_path}" || looks_like_placeholder "${android_store_password}" || looks_like_placeholder "${android_key_alias}" || looks_like_placeholder "${android_key_password}"; then
      echo "[mobile-release-build] Detected placeholder values in key.properties. Fill the real keystore path, passwords, and alias." >&2
    elif [[ -n "${android_keystore_path}" && ! -f "${android_keystore_path}" ]]; then
      echo "[mobile-release-build] Keystore file not found: ${android_keystore_path}" >&2
    fi
  fi
  if [[ "${ALLOW_DEBUG_SIGNING}" != "1" ]]; then
    echo "[mobile-release-build] Refusing to continue until release signing is configured or --allow-debug-signing is used for a non-store test build." >&2
    exit 1
  fi
fi

android_cmd=(flutter build)
if [[ "${ANDROID_FORMAT}" == "aab" ]]; then
  android_cmd+=(appbundle)
else
  android_cmd+=(apk)
fi
android_cmd+=("${flutter_args[@]}")

ios_cmd=(flutter build ipa "${flutter_args[@]}")
if [[ "${IOS_NO_CODESIGN}" == "1" ]]; then
  ios_cmd+=(--no-codesign)
elif [[ -n "${IOS_EXPORT_OPTIONS_PLIST}" ]]; then
  ios_cmd+=(--export-options-plist="${IOS_EXPORT_OPTIONS_PLIST}")
fi

echo "[mobile-release-build] Planned commands"
if [[ "${PLATFORM}" == "android" || "${PLATFORM}" == "all" ]]; then
  printf '  (cd %q &&' "${FLUTTER_DIR}"
  printf ' %q' "${android_cmd[@]}"
  printf ')\n'
fi
if [[ "${PLATFORM}" == "ios" || "${PLATFORM}" == "all" ]]; then
  printf '  (cd %q &&' "${FLUTTER_DIR}"
  printf ' %q' "${ios_cmd[@]}"
  printf ')\n'
fi

if [[ "${CHECK_ONLY}" == "1" ]]; then
  echo "[mobile-release-build] CHECK-ONLY OK"
  exit 0
fi

cd "${FLUTTER_DIR}"
flutter pub get

if [[ "${PLATFORM}" == "android" || "${PLATFORM}" == "all" ]]; then
  "${android_cmd[@]}"
fi

if [[ "${PLATFORM}" == "ios" || "${PLATFORM}" == "all" ]]; then
  "${ios_cmd[@]}"
fi

echo "[mobile-release-build] Done"
