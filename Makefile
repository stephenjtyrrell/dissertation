TF_DIR=infra/terraform
POLICY_TF_DIR=policies/terraform
POLICY_K8S_DIR=policies/kubernetes
TESTING_DIR=testing
TESTING_CONFIG?=$(TESTING_DIR)/config.env
CLOUD?=aws
ARGOCD_NAMESPACE?=argocd
ARGOCD_APP_NAME?=dissertation-sample-api
ARGOCD_APP_MANIFEST?=argocd/application.yaml
ARGOCD_TEST_APP_NAME?=dissertation-test-api
ARGOCD_TEST_APP_MANIFEST?=argocd/test-application.yaml
TEST_ID?=
RUN_SEQ?=1
GH_RUN_ID?=
PR_NUMBER?=
APP_NAME?=$(ARGOCD_APP_NAME)
APP_NAMESPACE?=
APP_TARGET?=manual
OUTCOME?=
DURATION_S?=
NOTES?=
RUN_ID?=
STAGE?=
POLICY_RULE?=
RESOURCE?=
VIOLATION_COUNT?=
BLOCKED?=

.PHONY: help tf-init tf-fmt tf-validate tf-plan tf-apply tf-destroy policy-tf policy-k8s k8s-dry-run argocd-apply argocd-status argocd-test argocd-test-app-apply argocd-test-app-status argocd-test-app-sync testing-init testing-record-run testing-record-policy testing-policy-negatives testing-capture-ci testing-capture-pr testing-capture-argocd testing-analyze clean all

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: tf-init tf-fmt tf-validate tf-plan policy-tf policy-k8s ## Run all checks

tf-init: ## Initialize Terraform
	terraform -chdir=$(TF_DIR)/$(CLOUD) init

tf-fmt: ## Format Terraform code
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-validate: ## Validate Terraform configuration
	terraform -chdir=$(TF_DIR)/$(CLOUD) validate

tf-plan: ## Generate Terraform plan (use CLOUD=aws|azure|gcp)
	terraform -chdir=$(TF_DIR)/$(CLOUD) plan -out=tfplan
	terraform -chdir=$(TF_DIR)/$(CLOUD) show -json tfplan > $(TF_DIR)/$(CLOUD)/tfplan.json

tf-apply: ## Apply Terraform changes (use CLOUD=aws|azure|gcp)
	terraform -chdir=$(TF_DIR)/$(CLOUD) apply

tf-destroy: ## Destroy Terraform resources (use CLOUD=aws|azure|gcp)
	terraform -chdir=$(TF_DIR)/$(CLOUD) destroy

policy-tf: ## Evaluate Terraform policies
	opa eval --fail-defined --format pretty --data $(POLICY_TF_DIR) --input $(POLICY_TF_DIR)/sample-tfplan.json "data.terraform.deny[_]"

policy-k8s: ## Evaluate Kubernetes policies
	conftest test k8s -p $(POLICY_K8S_DIR)

k8s-dry-run: ## Validate Kubernetes manifests with kubectl client-side dry run
	kubectl apply --dry-run=client -f k8s

argocd-apply: ## Apply ArgoCD Application manifest
	kubectl apply -f $(ARGOCD_APP_MANIFEST)

argocd-status: ## Show ArgoCD Application status
	kubectl get application -n $(ARGOCD_NAMESPACE) $(ARGOCD_APP_NAME)

argocd-test: ## Apply app and wait until ArgoCD reports Synced + Healthy
	kubectl apply -f $(ARGOCD_APP_MANIFEST)
	kubectl wait --for=jsonpath='{.status.sync.status}'=Synced application/$(ARGOCD_APP_NAME) -n $(ARGOCD_NAMESPACE) --timeout=300s
	kubectl wait --for=jsonpath='{.status.health.status}'=Healthy application/$(ARGOCD_APP_NAME) -n $(ARGOCD_NAMESPACE) --timeout=300s
	kubectl get application -n $(ARGOCD_NAMESPACE) $(ARGOCD_APP_NAME)
	kubectl get all -n dissertation

argocd-test-app-apply: ## Apply dedicated test ArgoCD Application manifest
	kubectl apply -f $(ARGOCD_TEST_APP_MANIFEST)

argocd-test-app-status: ## Show dedicated test ArgoCD Application status
	kubectl get application -n $(ARGOCD_NAMESPACE) $(ARGOCD_TEST_APP_NAME)

argocd-test-app-sync: ## Apply test app and wait until ArgoCD reports Synced + Healthy
	kubectl apply -f $(ARGOCD_TEST_APP_MANIFEST)
	kubectl wait --for=jsonpath='{.status.sync.status}'=Synced application/$(ARGOCD_TEST_APP_NAME) -n $(ARGOCD_NAMESPACE) --timeout=300s
	kubectl wait --for=jsonpath='{.status.health.status}'=Healthy application/$(ARGOCD_TEST_APP_NAME) -n $(ARGOCD_NAMESPACE) --timeout=300s
	kubectl get application -n $(ARGOCD_NAMESPACE) $(ARGOCD_TEST_APP_NAME)
	kubectl get all -n dissertation-test

testing-init: ## Create dissertation testing evidence layout and CSV headers
	@TESTING_CONFIG=$(TESTING_CONFIG) scripts/testing/init_evidence.sh

testing-record-run: ## Append a manual run_summary row
	@TESTING_CONFIG=$(TESTING_CONFIG) RUN_ID=$(RUN_ID) scripts/testing/record_run.sh "$(TEST_ID)" "$(RUN_SEQ)" "$(APP_TARGET)" "$(OUTCOME)" "$(DURATION_S)" "$(NOTES)"

testing-record-policy: ## Append a manual policy_events row
	@TESTING_CONFIG=$(TESTING_CONFIG) RUN_ID=$(RUN_ID) scripts/testing/record_policy_event.sh "$(TEST_ID)" "$(RUN_SEQ)" "$(STAGE)" "$(POLICY_RULE)" "$(RESOURCE)" "$(VIOLATION_COUNT)" "$(BLOCKED)"

testing-policy-negatives: ## Execute local negative-control fixtures for GOV-02, GOV-03 and GOV-04
	@TESTING_CONFIG=$(TESTING_CONFIG) scripts/testing/run_policy_negative_controls.sh

testing-capture-ci: ## Capture GitHub Actions evidence for a workflow run (requires gh auth)
	@TESTING_CONFIG=$(TESTING_CONFIG) RUN_ID=$(RUN_ID) scripts/testing/capture_ci_run.sh "$(TEST_ID)" "$(RUN_SEQ)" "$(GH_RUN_ID)" "$(APP_TARGET)"

testing-capture-pr: ## Capture PR approval/audit evidence (requires gh auth)
	@TESTING_CONFIG=$(TESTING_CONFIG) RUN_ID=$(RUN_ID) scripts/testing/capture_pr_audit.sh "$(TEST_ID)" "$(RUN_SEQ)" "$(PR_NUMBER)" "$(GH_RUN_ID)"

testing-capture-argocd: ## Capture ArgoCD and Kubernetes evidence for a live app
	@TESTING_CONFIG=$(TESTING_CONFIG) RUN_ID=$(RUN_ID) scripts/testing/capture_argocd_snapshot.sh "$(TEST_ID)" "$(RUN_SEQ)" "$(APP_NAME)" "$(APP_NAMESPACE)" "$(OUTCOME)"

testing-analyze: ## Build markdown summary statistics from collected evidence
	@python3 scripts/testing/analyze_results.py

clean: ## Clean generated files
	rm -f $(TF_DIR)/aws/*.tfplan $(TF_DIR)/aws/tfplan $(TF_DIR)/aws/tfplan*.json $(TF_DIR)/azure/*.tfplan $(TF_DIR)/azure/tfplan $(TF_DIR)/azure/tfplan*.json $(TF_DIR)/gcp/*.tfplan $(TF_DIR)/gcp/tfplan $(TF_DIR)/gcp/tfplan*.json
	rm -rf $(TF_DIR)/aws/.terraform $(TF_DIR)/azure/.terraform $(TF_DIR)/gcp/.terraform
	rm -f $(TF_DIR)/aws/.terraform.lock.hcl $(TF_DIR)/azure/.terraform.lock.hcl $(TF_DIR)/gcp/.terraform.lock.hcl
