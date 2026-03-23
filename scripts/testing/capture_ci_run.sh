#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 3 ]]; then
  fail "Usage: capture_ci_run.sh TEST_ID RUN_SEQ GH_RUN_ID [APP_TARGET]"
fi

TEST_ID="$1"
RUN_SEQ="$2"
GH_RUN_ID="$3"
APP_TARGET="${4:-github-actions}"

load_testing_env
init_evidence_layout
require_cmd gh
require_cmd jq
require_cmd python3

gh auth status >/dev/null 2>&1 || fail "GitHub CLI is not authenticated"

RUN_ID="${RUN_ID:-$(generate_run_id "${TEST_ID}" "${RUN_SEQ}")}"
BUNDLE_PATH=$(bundle_path "${RUN_ID}")
mkdir -p "${BUNDLE_PATH}"

gh run view "${GH_RUN_ID}" \
  --repo "${GITHUB_REPO}" \
  --json databaseId,displayTitle,workflowName,headSha,event,status,conclusion,createdAt,startedAt,updatedAt,url,jobs \
  > "${BUNDLE_PATH}/gh_run.json"

gh run view "${GH_RUN_ID}" --repo "${GITHUB_REPO}" --log > "${BUNDLE_PATH}/gh_run.log" || true
gh api "repos/${GITHUB_REPO}/actions/runs/${GH_RUN_ID}/artifacts" > "${BUNDLE_PATH}/artifacts.json"

HEAD_SHA=$(jq -r '.headSha // "unknown"' "${BUNDLE_PATH}/gh_run.json")
STATUS=$(jq -r '.status // ""' "${BUNDLE_PATH}/gh_run.json")
CONCLUSION=$(jq -r '.conclusion // ""' "${BUNDLE_PATH}/gh_run.json")
STARTED_AT=$(jq -r '.startedAt // ""' "${BUNDLE_PATH}/gh_run.json")
UPDATED_AT=$(jq -r '.updatedAt // ""' "${BUNDLE_PATH}/gh_run.json")
DURATION_S=$(duration_between "${STARTED_AT}" "${UPDATED_AT}")
OUTCOME="${CONCLUSION:-${STATUS}}"

append_csv_row \
  "${RUN_SUMMARY_CSV}" \
  "${RUN_ID}" \
  "${TEST_ID}" \
  "$(timestamp_utc)" \
  "${HEAD_SHA}" \
  "${APP_TARGET}" \
  "${OUTCOME}" \
  "${DURATION_S}" \
  "workflow=${GITHUB_WORKFLOW_NAME}; gh_run_id=${GH_RUN_ID}"

while IFS= read -r job_json; do
  [[ -z "${job_json}" ]] && continue

  JOB_NAME=$(jq -r '.name // "unknown"' <<<"${job_json}")
  JOB_STATUS=$(jq -r '.status // ""' <<<"${job_json}")
  JOB_CONCLUSION=$(jq -r '.conclusion // ""' <<<"${job_json}")
  JOB_STARTED_AT=$(jq -r '.startedAt // ""' <<<"${job_json}")
  JOB_COMPLETED_AT=$(jq -r '.completedAt // ""' <<<"${job_json}")
  JOB_DURATION_S=$(duration_between "${JOB_STARTED_AT}" "${JOB_COMPLETED_AT}")
  CLOUD="n/a"

  case "${JOB_NAME,,}" in
    *aws*)
      CLOUD="aws"
      ;;
    *azure*)
      CLOUD="azure"
      ;;
    *gcp*)
      CLOUD="gcp"
      ;;
  esac

  append_csv_row \
    "${CI_JOB_EVENTS_CSV}" \
    "${RUN_ID}" \
    "${JOB_NAME}" \
    "${CLOUD}" \
    "${JOB_STATUS}" \
    "${JOB_CONCLUSION}" \
    "${JOB_STARTED_AT}" \
    "${JOB_COMPLETED_AT}" \
    "${JOB_DURATION_S}"
done < <(jq -c '.jobs[]?' "${BUNDLE_PATH}/gh_run.json")

while IFS= read -r artifact_json; do
  [[ -z "${artifact_json}" ]] && continue

  append_csv_row \
    "${ARTIFACT_EVENTS_CSV}" \
    "${RUN_ID}" \
    "$(jq -r '.name // "unknown"' <<<"${artifact_json}")" \
    "$(jq -r '.size_in_bytes // ""' <<<"${artifact_json}")" \
    "$(jq -r '.expired // false' <<<"${artifact_json}")" \
    "$(jq -r '.created_at // ""' <<<"${artifact_json}")"
done < <(jq -c '.artifacts[]?' "${BUNDLE_PATH}/artifacts.json")

printf 'Captured CI evidence for %s into %s\n' "${RUN_ID}" "${BUNDLE_PATH}"

