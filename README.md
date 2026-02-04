# Dissertation Implementation: Vendor-Agnostic Multi-Cloud Pipeline

This repository provides a practical implementation for the dissertation topic:

`Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines`

## What is included

- `infra/terraform/`: Multi-cloud Infrastructure as Code (AWS, Azure, GCP) with a consistent interface
- `policies/`: OPA/Rego governance policies for Terraform and Kubernetes
- `.github/workflows/pipeline.yml`: CI pipeline for IaC validation and policy checks
- `k8s/app/`: Sample Kubernetes workload deployed through GitOps
- `argocd/application.yaml`: Argo CD app manifest for GitOps delivery

## Quick start

1. Select target cloud (`aws`, `azure`, or `gcp`) in Terraform variables.
2. Initialize and validate:

```bash
cd infra/terraform
terraform init
terraform validate
terraform plan -var="cloud=aws" -out=tfplan
terraform show -json tfplan > tfplan.json
```

3. Evaluate Terraform governance policies with OPA:

```bash
opa eval --fail-defined --format pretty --data ../../policies/terraform --input tfplan.json "data.terraform.deny"
```

4. Evaluate Kubernetes manifest governance policies:

```bash
conftest test ../../k8s/app -p ../../policies/kubernetes
```

Or use shortcuts:

```bash
make tf-init tf-validate
make policy-tf policy-k8s
```

## Notes

- This is intentionally provider-neutral at the orchestration level.
- Cloud-specific details are isolated inside provider modules.
- Governance controls are codified and enforced before deployment.
