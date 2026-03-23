#!/usr/bin/env bash
set -euo pipefail

COMMON_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "${COMMON_DIR}/../.." && pwd)
TESTING_DIR="${TESTING_DIR:-${REPO_ROOT}/testing}"
CONFIG_FILE="${TESTING_CONFIG:-${TESTING_DIR}/config.env}"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

load_testing_env() {
  if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck disable=SC1090
    source "${CONFIG_FILE}"
  fi

  EVIDENCE_DIR="${EVIDENCE_DIR:-${TESTING_DIR}/evidence}"
  BUNDLE_DIR="${BUNDLE_DIR:-${EVIDENCE_DIR}/bundles}"
  REPORT_DIR="${REPORT_DIR:-${TESTING_DIR}/reports/generated}"

  RUN_SUMMARY_CSV="${RUN_SUMMARY_CSV:-${EVIDENCE_DIR}/run_summary.csv}"
  POLICY_EVENTS_CSV="${POLICY_EVENTS_CSV:-${EVIDENCE_DIR}/policy_events.csv}"
  ARGOCD_EVENTS_CSV="${ARGOCD_EVENTS_CSV:-${EVIDENCE_DIR}/argocd_events.csv}"
  CI_JOB_EVENTS_CSV="${CI_JOB_EVENTS_CSV:-${EVIDENCE_DIR}/ci_job_events.csv}"
  ARTIFACT_EVENTS_CSV="${ARTIFACT_EVENTS_CSV:-${EVIDENCE_DIR}/artifact_events.csv}"
  APPROVAL_EVENTS_CSV="${APPROVAL_EVENTS_CSV:-${EVIDENCE_DIR}/approval_events.csv}"

  GITHUB_REPO="${GITHUB_REPO:-stephenjtyrrell/dissertation}"
  GITHUB_WORKFLOW_NAME="${GITHUB_WORKFLOW_NAME:-vendor-agnostic-multicloud-pipeline}"
  ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
  ARGOCD_APP_PRIMARY="${ARGOCD_APP_PRIMARY:-dissertation-sample-api}"
  ARGOCD_APP_SECONDARY="${ARGOCD_APP_SECONDARY:-dissertation-test-api}"
  ARGOCD_APP_PRIMARY_NAMESPACE="${ARGOCD_APP_PRIMARY_NAMESPACE:-dissertation}"
  ARGOCD_APP_SECONDARY_NAMESPACE="${ARGOCD_APP_SECONDARY_NAMESPACE:-dissertation-test}"
}

ensure_dirs() {
  mkdir -p "${EVIDENCE_DIR}" "${BUNDLE_DIR}" "${REPORT_DIR}"
}

ensure_csv() {
  local file="$1"
  local header="$2"

  if [[ ! -f "${file}" ]]; then
    printf '%s\n' "${header}" > "${file}"
  fi
}

init_evidence_layout() {
  ensure_dirs
  ensure_csv "${RUN_SUMMARY_CSV}" "run_id,test_id,timestamp_utc,commit_sha,app_target,outcome,duration_s,notes"
  ensure_csv "${POLICY_EVENTS_CSV}" "run_id,stage,policy_rule,resource,violation_count,blocked"
  ensure_csv "${ARGOCD_EVENTS_CSV}" "run_id,app_name,sync_status,health_status,sync_start,sync_end,sync_duration_s,self_heal"
  ensure_csv "${CI_JOB_EVENTS_CSV}" "run_id,job_name,cloud,status,conclusion,started_at,completed_at,duration_s"
  ensure_csv "${ARTIFACT_EVENTS_CSV}" "run_id,artifact_name,size_in_bytes,expired,created_at"
  ensure_csv "${APPROVAL_EVENTS_CSV}" "run_id,pr_number,review_decision,approval_count,artifacts_found,trace_complete,head_sha,author,updated_at,url"
}

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

timestamp_slug() {
  date -u +"%Y%m%d-%H%M"
}

generate_run_id() {
  local test_id="$1"
  local run_seq="$2"
  printf "%s-RUN%02d-%s" "${test_id}" "${run_seq}" "$(timestamp_slug)"
}

repo_head_sha() {
  git -C "${REPO_ROOT}" rev-parse HEAD 2>/dev/null || printf 'unknown'
}

bundle_path() {
  local run_id="$1"
  printf '%s/%s' "${BUNDLE_DIR}" "${run_id}"
}

csv_escape() {
  local value="${1:-}"
  value=${value//$'\n'/ }
  value=${value//$'\r'/ }
  value=${value//\"/\"\"}
  printf '"%s"' "${value}"
}

append_csv_row() {
  local file="$1"
  shift

  local first=1
  {
    for field in "$@"; do
      if [[ ${first} -eq 0 ]]; then
        printf ','
      fi
      csv_escape "${field}"
      first=0
    done
    printf '\n'
  } >> "${file}"
}

iso_to_epoch() {
  python3 - "$1" <<'PY'
from datetime import datetime, timezone
import sys

raw = sys.argv[1].strip()
if not raw:
    print("")
    raise SystemExit(0)

value = raw.replace("Z", "+00:00")
dt = datetime.fromisoformat(value)
if dt.tzinfo is None:
    dt = dt.replace(tzinfo=timezone.utc)
print(int(dt.timestamp()))
PY
}

duration_between() {
  local start="${1:-}"
  local end="${2:-}"

  if [[ -z "${start}" || -z "${end}" ]]; then
    printf ''
    return 0
  fi

  python3 - "${start}" "${end}" <<'PY'
from datetime import datetime, timezone
import sys

start_raw = sys.argv[1].replace("Z", "+00:00")
end_raw = sys.argv[2].replace("Z", "+00:00")
start_dt = datetime.fromisoformat(start_raw)
end_dt = datetime.fromisoformat(end_raw)
if start_dt.tzinfo is None:
    start_dt = start_dt.replace(tzinfo=timezone.utc)
if end_dt.tzinfo is None:
    end_dt = end_dt.replace(tzinfo=timezone.utc)
print(int((end_dt - start_dt).total_seconds()))
PY
}

assert_kube_context() {
  if [[ -z "${KUBE_CONTEXT:-}" ]]; then
    return 0
  fi

  local current_context
  current_context=$(kubectl config current-context 2>/dev/null || true)

  if [[ "${current_context}" != "${KUBE_CONTEXT}" ]]; then
    fail "kubectl context mismatch: expected ${KUBE_CONTEXT}, found ${current_context:-<none>}"
  fi
}

resolve_app_namespace() {
  local app_name="$1"
  local explicit_namespace="${2:-}"

  if [[ -n "${explicit_namespace}" ]]; then
    printf '%s' "${explicit_namespace}"
    return 0
  fi

  case "${app_name}" in
    "${ARGOCD_APP_PRIMARY}")
      printf '%s' "${ARGOCD_APP_PRIMARY_NAMESPACE}"
      ;;
    "${ARGOCD_APP_SECONDARY}")
      printf '%s' "${ARGOCD_APP_SECONDARY_NAMESPACE}"
      ;;
    *)
      fail "No namespace mapping found for app ${app_name}; pass APP_NAMESPACE explicitly"
      ;;
  esac
}

