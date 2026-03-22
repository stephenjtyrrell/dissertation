TF_DIR=infra/terraform
POLICY_TF_DIR=policies/terraform
POLICY_K8S_DIR=policies/kubernetes
CLOUD?=aws

.PHONY: help tf-init tf-fmt tf-validate tf-plan tf-apply tf-destroy policy-tf policy-k8s clean all

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
	opa eval --fail-defined --format pretty --data $(POLICY_TF_DIR) --input $(POLICY_TF_DIR)/sample-tfplan.json "data.terraform.deny"

policy-k8s: ## Evaluate Kubernetes policies
	conftest test k8s/app -p $(POLICY_K8S_DIR)

clean: ## Clean generated files
	rm -f $(TF_DIR)/*.tfplan $(TF_DIR)/*.tfplan.json $(TF_DIR)/.terraform.lock.hcl
	rm -rf $(TF_DIR)/.terraform
