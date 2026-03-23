# Dissertation Testing Harness

This directory turns the Chapter 5 to 7 test plan into a repeatable evidence workflow for the live Hetzner and GitHub setup.

## What is included

- `config.env.example`: environment-specific values for GitHub, Kubernetes, and ArgoCD.
- `evidence/*.csv`: canonical data files used for raw results and later analysis.
- `fixtures/terraform`: reproducible negative-control plans for `GOV-02` and `GOV-03`.
- `fixtures/kubernetes`: reproducible negative-control manifests for `GOV-04`.
- `scripts/testing/*`: capture, record, and analysis tooling.
- `dissertation_writeup_template.md`: structure for Chapters 5, 6, and 7.

## First-time setup

1. Copy `testing/config.env.example` to `testing/config.env`.
2. Set `GITHUB_REPO` to the repo used for the dissertation pipeline.
3. Set `KUBE_CONTEXT` to the Hetzner Kubernetes context you will use for live captures.
4. Confirm `kubectl config current-context` matches that context before any live `ArgoCD` capture.
5. Run `make testing-init`.

## Core commands

```bash
make testing-init
make testing-policy-negatives
make testing-capture-ci TEST_ID=GOV-01 RUN_SEQ=1 GH_RUN_ID=<actions_run_id>
make testing-capture-pr TEST_ID=GOV-05 RUN_SEQ=1 PR_NUMBER=<pr_number> GH_RUN_ID=<actions_run_id>
make testing-capture-argocd TEST_ID=SCL-02 RUN_SEQ=1 APP_NAME=dissertation-sample-api
make testing-record-run TEST_ID=SCL-05 RUN_SEQ=1 APP_TARGET=manual OUTCOME=scaled DURATION_S=97 NOTES="HPA scale-up observed"
make testing-analyze
```

## Evidence model

The minimum dissertation dataset is stored in:

- `testing/evidence/run_summary.csv`
- `testing/evidence/policy_events.csv`
- `testing/evidence/argocd_events.csv`

Additional helper datasets are also captured:

- `testing/evidence/ci_job_events.csv`
- `testing/evidence/artifact_events.csv`
- `testing/evidence/approval_events.csv`

Detailed per-run exports are written under `testing/evidence/bundles/<RUN_ID>/`.

## Test execution map

### Governance

- `GOV-01` Baseline compliance stability
  Use `make testing-capture-ci` after each successful GitHub Actions run.
- `GOV-02` Terraform tagging negative control
  Use `make testing-policy-negatives`. The harness runs three missing-tag fixtures.
- `GOV-03` Terraform security negative control
  Use `make testing-policy-negatives`. The harness runs public storage, missing encryption, and unrestricted ingress fixtures.
- `GOV-04` Kubernetes policy negative control
  Use `make testing-policy-negatives`. The harness runs missing labels, missing resources, and privileged container fixtures.
- `GOV-05` Deployment governance controls
  Use `make testing-capture-pr` for each PR-backed release candidate.
- `GOV-06` Drift and self-heal
  After applying live drift, use `make testing-capture-argocd` once when drift is detected and once when the app returns to `Healthy`. Record MTTR with `make testing-record-run`.

### Scalability

- `SCL-01` CI matrix predictability
  Use `make testing-capture-ci` for ten CI runs. The script extracts job-level timings into `ci_job_events.csv`.
- `SCL-02` ArgoCD sync latency app A
  Use `make testing-capture-argocd TEST_ID=SCL-02 ... APP_NAME=dissertation-sample-api` after each controlled commit.
- `SCL-03` ArgoCD sync latency app B
  Use `make testing-capture-argocd TEST_ID=SCL-03 ... APP_NAME=dissertation-test-api`.
- `SCL-04` Concurrent dual-app updates
  Capture both apps for the same commit window and record total convergence time with `make testing-record-run`.
- `SCL-05` Scaling response
  If HPA metrics are available, capture the app after scale-out and again after stabilisation. If not, use manual scale-response notes in `testing-record-run`.
- `SCL-06` Failure-recovery MTTR
  Intentionally break a manifest in a safe branch or test app, capture the failing state with `testing-capture-argocd`, then capture recovery and record MTTR with `testing-record-run`.

## Output and analysis

Run:

```bash
make testing-analyze
```

This generates:

- `testing/reports/generated/dissertation_testing_summary.md`

The generated report calculates:

- median duration
- Q1, Q3, and IQR
- p95
- outcome rates per test
- CI lane timings by cloud
- ArgoCD sync timings by app

## Current environment constraint

The current local kube context is not the Hetzner cluster. Live ArgoCD capture will fail until `kubectl` is pointed at the correct context and `argocd` is logged into the real server.

## Suggested run order

1. Execute `make testing-init`.
2. Run `make testing-policy-negatives` to populate controlled governance failures.
3. Capture ten clean CI runs with `make testing-capture-ci`.
4. Capture ten PR governance samples with `make testing-capture-pr`.
5. Capture ten ArgoCD sync samples for each live app.
6. Run drift, failure-recovery, and scaling scenarios.
7. Run `make testing-analyze`.
8. Use `testing/dissertation_writeup_template.md` to write Chapters 5 to 7.
