TF_DIR=infra/terraform
POLICY_TF_DIR=policies/terraform
POLICY_K8S_DIR=policies/kubernetes

.PHONY: tf-init tf-validate tf-plan policy-tf policy-k8s

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-validate:
	terraform -chdir=$(TF_DIR) validate

tf-plan:
	terraform -chdir=$(TF_DIR) plan -var="cloud=aws" -out=tfplan
	terraform -chdir=$(TF_DIR) show -json tfplan > tfplan.json

policy-tf:
	opa eval --fail-defined --format pretty --data $(POLICY_TF_DIR) --input $(POLICY_TF_DIR)/sample-tfplan.json "data.terraform.deny"

policy-k8s:
	conftest test k8s/app -p $(POLICY_K8S_DIR)
