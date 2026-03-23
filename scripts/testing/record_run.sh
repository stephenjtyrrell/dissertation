#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 5 ]]; then
  fail "Usage: record_run.sh TEST_ID RUN_SEQ APP_TARGET OUTCOME DURATION_S [NOTES] [COMMIT_SHA]"
fi

TEST_ID="$1"
RUN_SEQ="$2"
APP_TARGET="$3"
OUTCOME="$4"
DURATION_S="$5"
NOTES="${6:-}"
COMMIT_SHA="${7:-$(repo_head_sha)}"

load_testing_env
init_evidence_layout

RUN_ID="${RUN_ID:-$(generate_run_id "${TEST_ID}" "${RUN_SEQ}")}"

append_csv_row \
  "${RUN_SUMMARY_CSV}" \
  "${RUN_ID}" \
  "${TEST_ID}" \
  "$(timestamp_utc)" \
  "${COMMIT_SHA}" \
  "${APP_TARGET}" \
  "${OUTCOME}" \
  "${DURATION_S}" \
  "${NOTES}"

printf 'Recorded run summary for %s\n' "${RUN_ID}"

