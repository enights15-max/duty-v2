#!/usr/bin/env bash

set -euo pipefail

# Usage:
#   GITHUB_TOKEN=... ./scripts/ci/configure-branch-protection-github.sh owner repo [branch]
#
# Example:
#   GITHUB_TOKEN=... ./scripts/ci/configure-branch-protection-github.sh my-org duty-api main

if [[ $# -lt 2 ]]; then
  echo "Usage: GITHUB_TOKEN=... $0 <owner> <repo> [branch]"
  exit 1
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "Missing GITHUB_TOKEN"
  exit 1
fi

OWNER="$1"
REPO="$2"
BRANCH="${3:-main}"

API_URL="https://api.github.com/repos/${OWNER}/${REPO}/branches/${BRANCH}/protection"

read -r -d '' PAYLOAD <<'JSON' || true
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Actor Smoke Tests"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": true
}
JSON

curl -sS -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${API_URL}" \
  -d "${PAYLOAD}" >/tmp/branch-protection-response.json

echo "Branch protection configured for ${OWNER}/${REPO}:${BRANCH}"
echo "Response saved to /tmp/branch-protection-response.json"
