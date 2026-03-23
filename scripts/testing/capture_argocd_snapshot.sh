#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 3 ]]; then
  fail "Usage: capture_argocd_snapshot.sh TEST_ID RUN_SEQ APP_NAME [APP_NAMESPACE] [OUTCOME]"
fi

TEST_ID="$1"
RUN_SEQ="$2"
APP_NAME="$3"
APP_NAMESPACE="${4:-}"
OUTCOME_OVERRIDE="${5:-}"

load_testing_env
init_evidence_layout
require_cmd kubectl
require_cmd jq

assert_kube_context

RUN_ID="${RUN_ID:-$(generate_run_id "${TEST_ID}" "${RUN_SEQ}")}"
TARGET_NAMESPACE=$(resolve_app_namespace "${APP_NAME}" "${APP_NAMESPACE}")
BUNDLE_PATH=$(bundle_path "${RUN_ID}")
mkdir -p "${BUNDLE_PATH}"

kubectl get application -n "${ARGOCD_NAMESPACE}" "${APP_NAME}" -o json > "${BUNDLE_PATH}/application.json"
kubectl describe application -n "${ARGOCD_NAMESPACE}" "${APP_NAME}" > "${BUNDLE_PATH}/application.describe.txt"
kubectl get all -n "${TARGET_NAMESPACE}" -o wide > "${BUNDLE_PATH}/workload_resources.txt"
kubectl get hpa,pdb -n "${TARGET_NAMESPACE}" -o wide > "${BUNDLE_PATH}/scaling_and_disruption.txt"
kubectl get events -n "${TARGET_NAMESPACE}" --sort-by=.lastTimestamp > "${BUNDLE_PATH}/events.txt"

if command -v argocd >/dev/null 2>&1; then
  argocd app get "${APP_NAME}" -o json > "${BUNDLE_PATH}/argocd_app.json" || true
fi

SYNC_STATUS=$(jq -r '.status.sync.status // ""' "${BUNDLE_PATH}/application.json")
HEALTH_STATUS=$(jq -r '.status.health.status // ""' "${BUNDLE_PATH}/application.json")
SYNC_START=$(jq -r '.status.operationState.startedAt // ""' "${BUNDLE_PATH}/application.json")
SYNC_END=$(jq -r '.status.operationState.finishedAt // .status.reconciledAt // ""' "${BUNDLE_PATH}/application.json")
SYNC_DURATION_S=$(duration_between "${SYNC_START}" "${SYNC_END}")
SELF_HEAL=$(jq -r '.spec.syncPolicy.automated.selfHeal // false' "${BUNDLE_PATH}/application.json")
COMMIT_SHA=$(jq -r '.status.sync.revision // empty' "${BUNDLE_PATH}/application.json")
OUTCOME="${OUTCOME_OVERRIDE:-${HEALTH_STATUS}}"

append_csv_row \
  "${ARGOCD_EVENTS_CSV}" \
  "${RUN_ID}" \
  "${APP_NAME}" \
  "${SYNC_STATUS}" \
  "${HEALTH_STATUS}" \
  "${SYNC_START}" \
  "${SYNC_END}" \
  "${SYNC_DURATION_S}" \
  "${SELF_HEAL}"

append_csv_row \
  "${RUN_SUMMARY_CSV}" \
  "${RUN_ID}" \
  "${TEST_ID}" \
  "$(timestamp_utc)" \
  "${COMMIT_SHA:-$(repo_head_sha)}" \
  "${APP_NAME}" \
  "${OUTCOME}" \
  "${SYNC_DURATION_S}" \
  "namespace=${TARGET_NAMESPACE}; sync=${SYNC_STATUS}; health=${HEALTH_STATUS}"

printf 'Captured ArgoCD evidence for %s into %s\n' "${RUN_ID}" "${BUNDLE_PATH}"

