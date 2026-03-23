#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

load_testing_env
init_evidence_layout
require_cmd opa
require_cmd conftest
require_cmd jq

TF_POLICY_DIR="${REPO_ROOT}/policies/terraform"
K8S_POLICY_DIR="${REPO_ROOT}/policies/kubernetes"
TF_FIXTURE_DIR="${TESTING_DIR}/fixtures/terraform"
K8S_FIXTURE_DIR="${TESTING_DIR}/fixtures/kubernetes"

run_terraform_fixture() {
  local test_id="$1"
  local run_seq="$2"
  local fixture_name="$3"
  local policy_rule="$4"
  local resource="$5"

  local run_id
  run_id=$(generate_run_id "${test_id}" "${run_seq}")

  local bundle
  bundle=$(bundle_path "${run_id}")
  mkdir -p "${bundle}"

  local started_at finished_at duration_s outcome violations result_file
  started_at=$(date +%s)
  result_file="${bundle}/${fixture_name%.json}.opa.json"

  opa eval --format json --data "${TF_POLICY_DIR}" --input "${TF_FIXTURE_DIR}/${fixture_name}" "data.terraform.deny" > "${result_file}"

  finished_at=$(date +%s)
  duration_s=$((finished_at - started_at))
  violations=$(jq -r '.result[0].expressions[0].value | length' "${result_file}")
  outcome="unexpected-pass"

  if [[ "${violations}" -gt 0 ]]; then
    outcome="blocked"
  fi

  append_csv_row \
    "${RUN_SUMMARY_CSV}" \
    "${run_id}" \
    "${test_id}" \
    "$(timestamp_utc)" \
    "$(repo_head_sha)" \
    "policy-fixture:${fixture_name}" \
    "${outcome}" \
    "${duration_s}" \
    "expected_rule=${policy_rule}"

  append_csv_row \
    "${POLICY_EVENTS_CSV}" \
    "${run_id}" \
    "terraform-policy" \
    "${policy_rule}" \
    "${resource}" \
    "${violations}" \
    "$([[ "${violations}" -gt 0 ]] && printf 'true' || printf 'false')"
}

run_kubernetes_fixture() {
  local test_id="$1"
  local run_seq="$2"
  local fixture_name="$3"
  local policy_rule="$4"
  local resource="$5"

  local run_id
  run_id=$(generate_run_id "${test_id}" "${run_seq}")

  local bundle
  bundle=$(bundle_path "${run_id}")
  mkdir -p "${bundle}"

  local started_at finished_at duration_s outcome violations result_file
  started_at=$(date +%s)
  result_file="${bundle}/${fixture_name%.yaml}.conftest.json"

  conftest test "${K8S_FIXTURE_DIR}/${fixture_name}" -p "${K8S_POLICY_DIR}" --output json > "${result_file}" || true

  finished_at=$(date +%s)
  duration_s=$((finished_at - started_at))
  violations=$(jq -r '[.[].failures[]?] | length' "${result_file}")
  outcome="unexpected-pass"

  if [[ "${violations}" -gt 0 ]]; then
    outcome="blocked"
  fi

  append_csv_row \
    "${RUN_SUMMARY_CSV}" \
    "${run_id}" \
    "${test_id}" \
    "$(timestamp_utc)" \
    "$(repo_head_sha)" \
    "policy-fixture:${fixture_name}" \
    "${outcome}" \
    "${duration_s}" \
    "expected_rule=${policy_rule}"

  append_csv_row \
    "${POLICY_EVENTS_CSV}" \
    "${run_id}" \
    "kubernetes-policy" \
    "${policy_rule}" \
    "${resource}" \
    "${violations}" \
    "$([[ "${violations}" -gt 0 ]] && printf 'true' || printf 'false')"
}

run_terraform_fixture "GOV-02" 1 "missing-owner-plan.json" "required_tags" "module.aws.aws_vpc.this"
run_terraform_fixture "GOV-02" 2 "missing-cost-center-plan.json" "required_tags" "module.aws.aws_flow_log.this"
run_terraform_fixture "GOV-02" 3 "missing-environment-plan.json" "required_tags" "module.aws.aws_vpc.this"

run_terraform_fixture "GOV-03" 1 "public-storage-plan.json" "public_access" "module.aws.aws_s3_bucket.this"
run_terraform_fixture "GOV-03" 2 "unencrypted-s3-plan.json" "server_side_encryption" "module.aws.aws_s3_bucket.this"
run_terraform_fixture "GOV-03" 3 "unrestricted-ingress-plan.json" "unrestricted_ingress" "module.gcp.google_compute_firewall.this"

run_kubernetes_fixture "GOV-04" 1 "missing-labels.yaml" "required_labels" "Deployment/missing-labels-api"
run_kubernetes_fixture "GOV-04" 2 "missing-resources.yaml" "resource_requests_limits" "Deployment/missing-resources-api"
run_kubernetes_fixture "GOV-04" 3 "privileged-container.yaml" "security_context" "Deployment/privileged-api"

printf 'Executed local policy negative controls into %s\n' "${EVIDENCE_DIR}"

