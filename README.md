# Dissertation Implementation: Vendor-Agnostic Multi-Cloud Pipeline

This repository provides a practical implementation for the dissertation topic:

> **Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines**

---

## Table of Contents

- [What Is Included](#what-is-included)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Terraform Infrastructure](#terraform-infrastructure)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Policy Enforcement (OPA/Rego)](#policy-enforcement-oparego)
- [CI/CD Pipeline](#cicd-pipeline)
- [ArgoCD / GitOps Setup](#argocd--gitops-setup)
- [Pre-commit Hooks](#pre-commit-hooks)
- [Troubleshooting](#troubleshooting)
- [Security Features](#security-features)
- [Best Practices](#best-practices)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## What Is Included

| Component | Path | Description |
|-----------|------|-------------|
| Terraform IaC | `infra/terraform/` | Multi-cloud infrastructure (AWS, Azure, GCP) with consistent interface |
| OPA Policies | `policies/` | Governance policies for Terraform and Kubernetes |
| CI/CD Pipeline | `.github/workflows/pipeline.yml` | GitHub Actions for IaC validation and policy checks |
| Kubernetes App | `k8s/app/` | Production-ready workload with security best practices |
| ArgoCD Manifest | `argocd/application.yaml` | GitOps delivery via Argo CD |

---

## Architecture

This project demonstrates vendor-agnostic multi-cloud deployment through:

- **Abstraction Layer**: Consistent Terraform interface regardless of cloud provider
- **Policy-as-Code**: Automated governance enforcement with OPA
- **GitOps**: Declarative Kubernetes deployments via ArgoCD
- **CI/CD**: Automated validation and testing for all three cloud providers

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                          Developer Workflow                              │
│                                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│  │   Code   │───▶│   Git    │───▶│  GitHub  │───▶│   CI/CD  │             │
│  │  Changes │    │  Commit  │    │   Push   │    │ Pipeline │             │
│  └──────────┘    └──────────┘    └──────────┘    └─────┬────┘             │
└──────────────────────────────────────────────────────────┼──────────────┘
                                                           │
                    ┌──────────────────────────────────────┼───────────────┐
                    │          CI/CD Pipeline (GitHub Actions)             │
                    │                                                      │
                    │  ┌──────────────────────────────────────────────┐    │
                    │  │  1. Terraform Format & Validation            │    │
                    │  └──────────────┬───────────────────────────────┘    │
                    │                 │                                    │
                    │  ┌──────────────▼───────────────────────────────┐    │
                    │  │  2. Multi-Cloud Plan Generation              │    │
                    │  │     (AWS, Azure, GCP in parallel)            │    │
                    │  └──────────────┬───────────────────────────────┘    │
                    │                 │                                    │
                    │  ┌──────────────▼───────────────────────────────┐    │
                    │  │  3. Policy Evaluation (OPA)                  │    │
                    │  │     - Terraform Security Policies            │    │
                    │  │     - Kubernetes Governance Policies         │    │
                    │  └──────────────┬───────────────────────────────┘    │
                    │                 │                                    │
                    │                 │  [Policies Pass]                   │
                    └─────────────────┼────────────────────────────────────┘
                                      │
            ┌─────────────────────────┴─────────────────────────┐
            │                                                     │
            ▼                                                     ▼
┌───────────────────────┐                           ┌───────────────────────┐
│  Infrastructure Layer │                           │   Application Layer   │
│   (Terraform)         │                           │   (Kubernetes)        │
│                       │                           │                       │
│  ┌─────────────────┐  │                           │  ┌─────────────────┐  │
│  │  Cloud Provider │  │                           │  │   GitOps Sync   │  │
│  │   Selection     │  │                           │  │   (ArgoCD)      │  │
│  │   (aws/azure/   │  │                           │  └────────┬────────┘  │
│  │     gcp)        │  │                           │           │           │
│  └────────┬────────┘  │                           │  ┌────────▼────────┐  │
│           │           │                           │  │  Kubernetes     │  │
│  ┌────────▼────────┐  │                           │  │  Manifests      │  │
│  │  Module Routing │  │                           │  │  - Namespace    │  │
│  │  (Per-cloud     │  │                           │  │  - Deployment   │  │
│  │   directories)  │  │                           │  │  - Service      │  │
│  └────────┬────────┘  │                           │  │  - HPA          │  │
│           │           │                           │  │  - PDB          │  │
│  ┌────────▼────────┐  │                           │  └─────────────────┘  │
│  │ Provider Module │  │                           │                       │
│  │  aws/azure/gcp  │  │                           │                       │
│  └────────┬────────┘  │                           │                       │
│           │           │                           │                       │
│  ┌────────▼────────┐  │                           │                       │
│  │  Infrastructure │  │                           │                       │
│  │   Resources     │  │                           │                       │
│  │  - VPC/VNet     │  │                           │                       │
│  │  - Subnets      │  │                           │                       │
│  │  - Tags/Labels  │  │                           │                       │
│  └─────────────────┘  │                           │                       │
└───────────────────────┘                           └───────────────────────┘
```

### Data Flow

```text
Developer → Git → GitHub → CI/CD Pipeline

                              ↓

                    Policy Check         Format/Validate

                              ↓

                        [Pass/Fail]

                              ↓

            Infrastructure (Terraform)    Application (ArgoCD → K8s)
```

### Component Details

| Layer | Purpose | Key Benefits |
|-------|---------|--------------|
| Infrastructure (Terraform) | Provision cloud infrastructure in a vendor-agnostic manner | Clear separation per cloud, consistent patterns, independent deployments |
| Policy (OPA/Rego) | Enforce governance and security before deployment | Shift-left security, automated compliance, policy-as-code |
| CI/CD (GitHub Actions) | Automate validation across all cloud providers | Parallel testing, early detection, audit trail |
| Application (Kubernetes) | Deploy applications using GitOps methodology | Declarative, Git as source of truth, auto-sync, rollback |

---

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.6.0
- [OPA](https://www.openpolicyagent.org/docs/latest/#1-download-opa) >= 0.50.0
- [Conftest](https://www.conftest.dev/install/) >= 0.40.0
- Cloud provider credentials (AWS, Azure, or GCP)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (for Kubernetes deployment)
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) (for GitOps)

---

## Quick Start

### 1. Configure Cloud Provider

Select target cloud (`aws`, `azure`, or `gcp`) and set up credentials.

**AWS:**

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Azure:**

```bash
az login
```

**GCP:**

```bash
gcloud auth application-default login
export GOOGLE_PROJECT="your-project-id"
```

### 2. Initialize and Deploy Infrastructure

```bash
# Copy and customize terraform variables for your target cloud
# For AWS:
cp infra/terraform/terraform.tfvars.example infra/terraform/aws/terraform.tfvars

# Initialize and validate (replace 'aws' with 'azure' or 'gcp' as needed)
cd infra/terraform/aws
terraform init
terraform validate
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
```

### 3. Evaluate Governance Policies

**Terraform policies:**

```bash
opa eval --fail-defined --format pretty \
  --data ../../../policies/terraform \
  --input tfplan.json \
  "data.terraform.deny"
```

**Kubernetes policies:**

```bash
conftest test k8s/app -p policies/kubernetes
```

---

## Project Structure

```
.
├── .github/                       # CI/CD workflows
├── argocd/                        # ArgoCD application manifest
├── infra/terraform/               # Multi-cloud Terraform IaC
├── k8s/app/                       # Kubernetes manifests
├── policies/                      # OPA/Rego policies
├── .pre-commit-config.yaml        # Pre-commit hook configuration
├── LICENSE                        # MIT License
├── Makefile                       # Build automation
└── README.md                      # This file
```

---

## Terraform Infrastructure

### Directory Layout

Each cloud provider has its own isolated directory with independent provider configuration, state, and variables. This avoids cross-cloud authentication issues and allows independent deployments.

```
infra/terraform/
├── aws/           # AWS-specific configuration
├── azure/         # Azure-specific configuration
├── gcp/           # GCP-specific configuration
└── modules/       # Cloud provider modules
    ├── aws/
    ├── azure/
    └── gcp/
```

### Cloud Provider Details

#### AWS Module

**Resources created:**
- VPC with DNS support and hostnames enabled
- Subnet in the first availability zone
- VPC Flow Logs for network traffic monitoring
- CloudWatch Log Group for flow log storage
- IAM role and policy for VPC Flow Logs
- All resources tagged according to governance requirements

```hcl
module "aws" {
  source            = "../modules/aws"
  name_prefix       = "my-project-dev"
  cidr_block        = "10.42.0.0/16"
  subnet_cidr_block = "10.42.1.0/24"
  tags = {
    owner       = "platform-team"
    cost_center = "cc-001"
    compliance  = "baseline"
  }
}
```

| Input | Description | Type |
|-------|-------------|------|
| `name_prefix` | Prefix for resource names | `string` |
| `cidr_block` | VPC CIDR block | `string` |
| `subnet_cidr_block` | Subnet CIDR block | `string` |
| `tags` | Tags to apply to all resources | `map(string)` |

**Requirements:** Terraform >= 1.6.0, AWS provider ~> 6.31

#### Azure Module

**Resources created:**
- Resource Group
- Virtual Network
- Subnet
- All resources tagged according to governance requirements

```hcl
module "azure" {
  source            = "../modules/azure"
  name_prefix       = "my-project-dev"
  location          = "eastus"
  cidr_block        = "10.42.0.0/16"
  subnet_cidr_block = "10.42.1.0/24"
  tags = {
    owner       = "platform-team"
    cost_center = "cc-001"
    compliance  = "baseline"
  }
}
```

| Input | Description | Type |
|-------|-------------|------|
| `name_prefix` | Prefix for resource names | `string` |
| `location` | Azure region location | `string` |
| `cidr_block` | VNet CIDR block | `string` |
| `subnet_cidr_block` | Subnet CIDR block | `string` |
| `tags` | Tags to apply to all resources | `map(string)` |

**Requirements:** Terraform >= 1.6.0, AzureRM provider ~> 4.58

#### GCP Module

**Resources created:**
- VPC Network (custom mode, no auto-created subnets)
- Subnet with specified CIDR range

> **Note:** GCP Compute networks and subnetworks do not support labels directly.

```hcl
module "gcp" {
  source            = "../modules/gcp"
  name_prefix       = "my-project-dev"
  region            = "us-central1"
  cidr_block        = "10.42.0.0/16"
  subnet_cidr_block = "10.42.1.0/24"
}
```

| Input | Description | Type |
|-------|-------------|------|
| `name_prefix` | Prefix for resource names | `string` |
| `region` | GCP region | `string` |
| `cidr_block` | VPC CIDR block (kept for interface consistency) | `string` |
| `subnet_cidr_block` | Subnet CIDR block | `string` |

**Requirements:** Terraform >= 1.6.0, Google provider ~> 7.18

### Backend Configuration

Each cloud directory has a `backend.tf.example` file. To use a remote backend:

1. Choose your target cloud directory (`aws/`, `azure/`, or `gcp/`).
2. Copy `backend.tf.example` to `backend.tf`.
3. Edit with your backend-specific settings.

| Cloud | Backend | Lock Mechanism |
|-------|---------|----------------|
| AWS | S3 bucket | DynamoDB table |
| Azure | Azure Storage Account | Built-in |
| GCP | Cloud Storage bucket | Built-in |

---

## Kubernetes Deployment

The sample application includes production-ready configurations:

- Resource requests and limits
- Liveness and readiness probes
- Security contexts (non-root, read-only filesystem, drop all capabilities)
- Pod Disruption Budget for high availability
- Horizontal Pod Autoscaler (CPU and memory based)
- Proper labeling for governance compliance
- Volume mounts for nginx with read-only root filesystem

### Manifests

| File | Kind | Purpose |
|------|------|---------|
| `namespace.yaml` | Namespace | Creates `dissertation` namespace |
| `deployment.yaml` | Deployment | nginx 1.27 with 2 replicas, full security context |
| `service.yaml` | Service | TCP port 80 exposure |
| `hpa.yaml` | HorizontalPodAutoscaler | Auto-scale 2–10 pods (70% CPU, 80% memory) |
| `pdb.yaml` | PodDisruptionBudget | Minimum 1 pod always available |

### Scalability Features

1. Horizontal Scaling: HPA automatically scales pods based on CPU and memory.
2. High Availability: PDB ensures minimum availability during disruptions.
3. Resource Management: Defined requests and limits enable efficient scheduling.

---

## Policy Enforcement (OPA/Rego)

### Kubernetes Policies

**Location:** `policies/kubernetes/required-labels.rego`

| Rule | Description |
|------|-------------|
| Required Labels | `app.kubernetes.io/name`, `app.kubernetes.io/part-of`, `owner`, `compliance` |
| Resource Limits | All containers must define `resources.requests` and `resources.limits` |
| Security Context | Must be defined; `privileged` must not be true; `readOnlyRootFilesystem` should be true |
| Health Probes | All containers should define `livenessProbe` and `readinessProbe` |

**Test locally:**

```bash
conftest test k8s/app -p policies/kubernetes
```

### Terraform Policies

**Location:** `policies/terraform/security.rego`

| Rule | Description |
|------|-------------|
| Required Tags | `owner`, `cost_center`, `compliance`, `project`, `environment`, `managed_by` |
| Storage Security | S3/Azure Storage/GCS must not allow public access; S3 must have encryption; Azure must enable HTTPS only |
| Network Security | AWS VPCs should have Flow Logs enabled; GCP firewalls should not allow unrestricted `0.0.0.0/0` ingress |

> **Note:** Certain resource types that don't support tags/labels are automatically exempted (e.g., `aws_iam_role_policy`, `azurerm_subnet`, `google_compute_network`).

**Test locally:**

```bash
# Against sample plan
opa eval --fail-defined --format pretty \
  --data policies/terraform \
  --input policies/terraform/sample-tfplan.json \
  "data.terraform.deny"

# Against a real plan
terraform -chdir=infra/terraform/aws plan -out=tfplan
terraform -chdir=infra/terraform/aws show -json tfplan > tfplan.json

opa eval --fail-defined --format pretty \
  --data policies/terraform \
  --input tfplan.json \
  "data.terraform.deny"
```

### Adding New Policies

**Kubernetes:**

```rego
deny[msg] {
  # Your condition logic
  msg := sprintf("Your error message: %v", [variables])
}
```

**Terraform:**

```rego
deny contains msg if {
  some rc in input.resource_changes
  # Your condition logic
  msg := sprintf("Your error message: %v", [variables])
}
```

---

## CI/CD Pipeline

### Overview

The GitHub Actions workflow (`.github/workflows/pipeline.yml`) runs on every push to `main` and on all pull requests. It uses a matrix strategy to test all three cloud providers in parallel.

**Pipeline stages:**

1. Terraform Format Check — Ensures code consistency
2. Terraform Init and Validate — Verifies syntax (`-backend=false` for CI)
3. Terraform Plan — Generates plans per cloud provider
4. OPA Policy Evaluation — Runs against both the sample plan and the real plan
5. Conftest Kubernetes Policy Evaluation — Validates K8s manifests
6. Artifact Upload — Saves Terraform plans for review (30-day retention)

### GitHub Repository Secrets

Configure these in **Settings → Secrets and variables → Actions → New repository secret**.

#### AWS

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN       (optional)
AWS_REGION              (optional, defaults to us-east-1)
```

#### Azure

```
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
```

To generate Azure credentials:

```bash
az login
az account show --query id -o tsv          # subscription id
az account show --query tenantId -o tsv    # tenant id

az ad sp create-for-rbac \
  --name "dissertation-terraform" \
  --role "Contributor" \
  --scopes "/subscriptions/<subscription-id>" \
  --sdk-auth
```

Map the service principal output:
- `clientId` → `ARM_CLIENT_ID`
- `clientSecret` → `ARM_CLIENT_SECRET`
- `tenantId` → `ARM_TENANT_ID`
- `subscriptionId` → `ARM_SUBSCRIPTION_ID`

> **Troubleshooting 403 AuthorizationFailed:** Ensure the role assignment exists at the subscription level:
> ```bash
> az role assignment create \
>   --assignee "<client-id>" \
>   --role "Contributor" \
>   --scope "/subscriptions/<subscription-id>"
> ```

#### GCP

```
GCP_PROJECT_ID
GCP_SA_KEY              (service account JSON key)
```

### Dependabot

Dependabot is configured (`.github/dependabot.yml`) to check weekly for:

- GitHub Actions version updates
- Terraform provider updates (for all 6 Terraform directories)

### Customisation

**Test only specific clouds:**

```yaml
strategy:
  matrix:
    cloud: [aws]  # Only test AWS
```

**Add deployment step (use with caution):**

```yaml
- name: Terraform Apply
  if: github.ref == 'refs/heads/main'
  run: terraform -chdir=infra/terraform/${{ matrix.cloud }} apply -auto-approve
```

---

## ArgoCD / GitOps Setup

### Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
```

### Access ArgoCD UI

```bash
# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Access at https://localhost:8080 (admin / <password from above>)
```

### Deploy the Application

1. Update `argocd/application.yaml` with your repository URL.

```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/dissertation
```

2. Apply.

```bash
kubectl apply -f argocd/application.yaml
```

3. Verify.

```bash
kubectl get application -n argocd
kubectl get all -n dissertation
```

The ArgoCD application is configured with:

- Automated sync with self-healing and pruning
- Auto namespace creation (`CreateNamespace=true`)
- Retry policy with exponential backoff (5 attempts, max 3 minutes)

---

## Pre-commit Hooks

### Setup

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files   # Test on all files
```

### What Gets Checked

- Trailing whitespace and end-of-file fixes
- YAML syntax validation
- Large file detection
- Merge conflict markers
- Private key detection
- Terraform formatting and validation
- Terraform documentation generation
- Rego policy verification via Conftest

### Skip Hooks (When Necessary)

```bash
git commit --no-verify -m "urgent fix"
SKIP=terraform_fmt git commit -m "commit message"
```

---

## Troubleshooting

### Terraform Issues

**Provider authentication fails:**

```bash
aws sts get-caller-identity  # AWS
az account show              # Azure
gcloud auth list             # GCP
```

**Backend initialization fails:**

- Ensure you've copied `backend.tf.example` to `backend.tf` and configured it
- Check that you have permissions to access the state storage

**Run validation locally:**

```bash
make tf-init CLOUD=aws
make tf-validate CLOUD=aws
```

### Policy Issues

**Validate Rego syntax:**

```bash
opa check policies/terraform/security.rego
opa check policies/kubernetes/required-labels.rego
```

**Test with verbose output:**

```bash
opa eval --format pretty \
  --data policies/terraform \
  --input policies/terraform/sample-tfplan.json \
  "data.terraform"
```

**Kubernetes policies fail:**

- Ensure all required labels are present on every resource
- Check that resource limits are defined on all containers
- Verify security contexts are properly configured

### ArgoCD Issues

```bash
kubectl logs -n argocd deployment/argocd-application-controller
kubectl describe application dissertation-sample-api -n argocd
```

---

## Security Features

1. Policy Enforcement — Automated validation before any deployment
2. Security Contexts — Non-root containers, read-only filesystems, dropped capabilities
3. Network Security — HTTPS-only, no public access by default, VPC Flow Logs
4. Secret Management — All credentials stored in GitHub Secrets, never committed
5. Dependency Scanning — Dependabot monitors for outdated dependencies
6. Pre-commit Hooks — Private key detection, secret scanning before commits

---

## Best Practices

1. Always create feature branches — Don't push directly to main
2. Wait for CI checks before merging pull requests
3. Review policy violations carefully — they're there for a reason
4. Keep dependencies updated — Merge Dependabot PRs regularly
5. Monitor ArgoCD — Ensure applications stay in sync
6. Use pre-commit hooks — Catch issues before they reach CI

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This implementation demonstrates concepts from the dissertation:

*"Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines"*
