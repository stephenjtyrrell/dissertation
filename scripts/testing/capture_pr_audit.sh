#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 3 ]]; then
  fail "Usage: capture_pr_audit.sh TEST_ID RUN_SEQ PR_NUMBER [GH_RUN_ID]"
fi

TEST_ID="$1"
RUN_SEQ="$2"
PR_NUMBER="$3"
GH_RUN_ID="${4:-}"

load_testing_env
init_evidence_layout
require_cmd gh
require_cmd jq

gh auth status >/dev/null 2>&1 || fail "GitHub CLI is not authenticated"

RUN_ID="${RUN_ID:-$(generate_run_id "${TEST_ID}" "${RUN_SEQ}")}"
BUNDLE_PATH=$(bundle_path "${RUN_ID}")
mkdir -p "${BUNDLE_PATH}"

gh pr view "${PR_NUMBER}" \
  --repo "${GITHUB_REPO}" \
  --json number,title,headRefOid,reviewDecision,reviews,author,createdAt,updatedAt,url \
  > "${BUNDLE_PATH}/pull_request.json"

APPROVAL_COUNT=$(jq -r '[.reviews[]? | select(.state == "APPROVED") | .author.login] | unique | length' "${BUNDLE_PATH}/pull_request.json")
REVIEW_DECISION=$(jq -r '.reviewDecision // ""' "${BUNDLE_PATH}/pull_request.json")
HEAD_SHA=$(jq -r '.headRefOid // "unknown"' "${BUNDLE_PATH}/pull_request.json")
AUTHOR=$(jq -r '.author.login // "unknown"' "${BUNDLE_PATH}/pull_request.json")
UPDATED_AT=$(jq -r '.updatedAt // ""' "${BUNDLE_PATH}/pull_request.json")
CREATED_AT=$(jq -r '.createdAt // ""' "${BUNDLE_PATH}/pull_request.json")
URL=$(jq -r '.url // ""' "${BUNDLE_PATH}/pull_request.json")
TRACE_COMPLETE="false"

if [[ -n "${HEAD_SHA}" && -n "${AUTHOR}" && -n "${UPDATED_AT}" && -n "${URL}" ]]; then
  TRACE_COMPLETE="true"
fi

ARTIFACTS_FOUND=""
if [[ -n "${GH_RUN_ID}" ]]; then
  gh api "repos/${GITHUB_REPO}/actions/runs/${GH_RUN_ID}/artifacts" > "${BUNDLE_PATH}/pull_request_artifacts.json"
  ARTIFACTS_FOUND=$(jq -r '.artifacts | length' "${BUNDLE_PATH}/pull_request_artifacts.json")
fi

append_csv_row \
  "${APPROVAL_EVENTS_CSV}" \
  "${RUN_ID}" \
  "${PR_NUMBER}" \
  "${REVIEW_DECISION}" \
  "${APPROVAL_COUNT}" \
  "${ARTIFACTS_FOUND}" \
  "${TRACE_COMPLETE}" \
  "${HEAD_SHA}" \
  "${AUTHOR}" \
  "${UPDATED_AT}" \
  "${URL}"

append_csv_row \
  "${RUN_SUMMARY_CSV}" \
  "${RUN_ID}" \
  "${TEST_ID}" \
  "$(timestamp_utc)" \
  "${HEAD_SHA}" \
  "pull-request" \
  "${REVIEW_DECISION}" \
  "$(duration_between "${CREATED_AT}" "${UPDATED_AT}")" \
  "pr=${PR_NUMBER}; approvals=${APPROVAL_COUNT}; artifacts=${ARTIFACTS_FOUND:-n/a}"

printf 'Captured PR audit evidence for %s into %s\n' "${RUN_ID}" "${BUNDLE_PATH}"

