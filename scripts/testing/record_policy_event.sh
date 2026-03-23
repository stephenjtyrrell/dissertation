#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 7 ]]; then
  fail "Usage: record_policy_event.sh TEST_ID RUN_SEQ STAGE POLICY_RULE RESOURCE VIOLATION_COUNT BLOCKED"
fi

TEST_ID="$1"
RUN_SEQ="$2"
STAGE="$3"
POLICY_RULE="$4"
RESOURCE="$5"
VIOLATION_COUNT="$6"
BLOCKED="$7"

load_testing_env
init_evidence_layout

RUN_ID="${RUN_ID:-$(generate_run_id "${TEST_ID}" "${RUN_SEQ}")}"

append_csv_row \
  "${POLICY_EVENTS_CSV}" \
  "${RUN_ID}" \
  "${STAGE}" \
  "${POLICY_RULE}" \
  "${RESOURCE}" \
  "${VIOLATION_COUNT}" \
  "${BLOCKED}"

printf 'Recorded policy event for %s\n' "${RUN_ID}"

