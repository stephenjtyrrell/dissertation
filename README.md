# Dissertation Implementation: Vendor-Agnostic Multi-Cloud Pipeline# Dissertation Implementation: Vendor-Agnostic Multi-Cloud Pipeline



This repository provides a practical implementation for the dissertation topic:This repository provides a practical implementation for the dissertation topic:



> **Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines**`Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines`



---## What is included



## Table of Contents- **`infra/terraform/`**: Multi-cloud Infrastructure as Code (AWS, Azure, GCP) with a consistent interface

- **`policies/`**: OPA/Rego governance policies for Terraform and Kubernetes

- [What is Included](#what-is-included)- **`.github/workflows/pipeline.yml`**: CI pipeline for IaC validation and policy checks across all cloud providers

- [Architecture](#architecture)- **`k8s/app/`**: Production-ready Kubernetes workload with security best practices, deployed through GitOps

- [Prerequisites](#prerequisites)- **`argocd/application.yaml`**: Argo CD app manifest for GitOps delivery

- [Quick Start](#quick-start)

- [Using the Makefile](#using-the-makefile)## Architecture

- [Project Structure](#project-structure)

- [Terraform Infrastructure](#terraform-infrastructure)This project demonstrates vendor-agnostic multi-cloud deployment through:

- [Kubernetes Deployment](#kubernetes-deployment)- **Abstraction Layer**: Consistent Terraform interface regardless of cloud provider

- [Policy Enforcement (OPA/Rego)](#policy-enforcement-oparego)- **Policy-as-Code**: Automated governance enforcement with OPA

- [CI/CD Pipeline](#cicd-pipeline)- **GitOps**: Declarative Kubernetes deployments via ArgoCD

- [ArgoCD / GitOps Setup](#argocd--gitops-setup)- **CI/CD**: Automated validation and testing for all three cloud providers

- [Pre-commit Hooks](#pre-commit-hooks)

- [Troubleshooting](#troubleshooting)## Prerequisites

- [License](#license)

- [Terraform](https://www.terraform.io/downloads.html) >= 1.6.0

---- [OPA](https://www.openpolicyagent.org/docs/latest/#1-download-opa) >= 0.50.0

- [Conftest](https://www.conftest.dev/install/) >= 0.40.0

## What is Included- Cloud provider credentials (AWS, Azure, or GCP)

- [kubectl](https://kubernetes.io/docs/tasks/tools/) (for Kubernetes deployment)

| Component | Path | Description |- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) (for GitOps)

|-----------|------|-------------|

| Terraform IaC | `infra/terraform/` | Multi-cloud infrastructure (AWS, Azure, GCP) with consistent interface |## Quick start

| OPA Policies | `policies/` | Governance policies for Terraform and Kubernetes |

| CI/CD Pipeline | `.github/workflows/pipeline.yml` | GitHub Actions for IaC validation and policy checks |### 1. Configure Cloud Provider

| Kubernetes App | `k8s/app/` | Production-ready workload with security best practices |

| ArgoCD Manifest | `argocd/application.yaml` | GitOps delivery via Argo CD |Select target cloud (`aws`, `azure`, or `gcp`) and set up credentials:



---**AWS:**

```bash

## Architectureexport AWS_ACCESS_KEY_ID="your-access-key"

export AWS_SECRET_ACCESS_KEY="your-secret-key"

This project demonstrates vendor-agnostic multi-cloud deployment through:export AWS_DEFAULT_REGION="us-east-1"

- **Abstraction Layer**: Consistent Terraform interface regardless of cloud provider```

- **Policy-as-Code**: Automated governance enforcement with OPA

- **GitOps**: Declarative Kubernetes deployments via ArgoCD**Azure:**

- **CI/CD**: Automated validation and testing for all three cloud providers```bash

az login

``````

┌─────────────────────────────────────────────────────────────────────────┐

│                          Developer Workflow                              │**GCP:**

│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐         │```bash

│  │   Code   │───▶│   Git    │───▶│  GitHub  │───▶│   CI/CD  │         │gcloud auth application-default login

│  │  Changes │    │  Commit  │    │   Push   │    │ Pipeline │         │export GOOGLE_PROJECT="your-project-id"

│  └──────────┘    └──────────┘    └──────────┘    └─────┬────┘         │```

└──────────────────────────────────────────────────────────┼──────────────┘

                                                            │### 2. Initialize and Deploy Infrastructure

                    ┌───────────────────────────────────────┼───────────────┐

                    │          CI/CD Pipeline (GitHub Actions)              │```bash

                    │                                                        │# Copy and customize terraform variables for your target cloud

                    │  ┌──────────────────────────────────────────────┐    │# For AWS:

                    │  │  1. Terraform Format & Validation            │    │cp infra/terraform/terraform.tfvars.example infra/terraform/aws/terraform.tfvars

                    │  └──────────────┬───────────────────────────────┘    │

                    │                 │                                     │# Initialize and validate (replace 'aws' with 'azure' or 'gcp' as needed)

                    │  ┌──────────────▼───────────────────────────────┐    │cd infra/terraform/aws

                    │  │  2. Multi-Cloud Plan Generation              │    │terraform init

                    │  │     (AWS, Azure, GCP in parallel)            │    │terraform validate

                    │  └──────────────┬───────────────────────────────┘    │terraform plan -out=tfplan

                    │                 │                                     │terraform show -json tfplan > tfplan.json

                    │  ┌──────────────▼───────────────────────────────┐    │```

                    │  │  3. Policy Evaluation (OPA)                  │    │

                    │  │     - Terraform Security Policies            │    │### 3. Evaluate Governance Policies

                    │  │     - Kubernetes Governance Policies         │    │

                    │  └──────────────┬───────────────────────────────┘    │**Terraform policies:**

                    │                 │                                     │```bash

                    │                 │ [Policies Pass]                     │opa eval --fail-defined --format pretty \

                    └─────────────────┼─────────────────────────────────────┘  --data ../../../policies/terraform \

                                      │  --input tfplan.json \

            ┌─────────────────────────┴─────────────────────────┐  "data.terraform.deny"

            │                                                     │```

            ▼                                                     ▼

┌───────────────────────┐                           ┌───────────────────────┐**Kubernetes policies:**

│  Infrastructure Layer │                           │   Application Layer   │```bash

│   (Terraform)         │                           │   (Kubernetes)        │conftest test ../../../k8s/app -p ../../../policies/kubernetes

│                       │                           │                       │```

│  ┌─────────────────┐  │                           │  ┌─────────────────┐  │

│  │  Cloud Provider │  │                           │  │   GitOps Sync   │  │### 4. Apply Infrastructure (if policies pass)

│  │   Selection     │  │                           │  │   (ArgoCD)      │  │

│  │   (aws/azure/   │  │                           │  └────────┬────────┘  │```bash

│  │     gcp)        │  │                           │           │           │terraform apply

│  └────────┬────────┘  │                           │  ┌────────▼────────┐  │```

│           │           │                           │  │  Kubernetes     │  │

│  ┌────────▼────────┐  │                           │  │  Manifests      │  │## Using the Makefile

│  │  Module Routing │  │                           │  │  - Namespace    │  │

│  │  (Per-cloud     │  │                           │  │  - Deployment   │  │The project includes a comprehensive Makefile for common tasks:

│  │   directories)  │  │                           │  │  - Service      │  │

│  └────────┬────────┘  │                           │  │  - HPA          │  │```bash

│           │           │                           │  │  - PDB          │  │# Show all available commands

│  ┌────────▼────────┐  │                           │  └─────────────────┘  │make help

│  │ Provider Module │  │                           │                       │

│  │  aws/azure/gcp  │  │                           │                       │# Run all checks

│  └────────┬────────┘  │                           │                       │make all

│           │           │                           │                       │

│  ┌────────▼────────┐  │                           │                       │# Terraform operations (specify CLOUD=aws, azure, or gcp)

│  │  Infrastructure │  │                           │                       │make tf-init CLOUD=aws       # Initialize Terraform

│  │   Resources     │  │                           │                       │make tf-fmt                  # Format Terraform code

│  │  - VPC/VNet     │  │                           │                       │make tf-validate CLOUD=aws   # Validate configuration

│  │  - Subnets      │  │                           │                       │make tf-plan CLOUD=aws       # Generate plan for specific cloud

│  │  - Tags/Labels  │  │                           │                       │make tf-apply CLOUD=azure    # Apply changes

│  └─────────────────┘  │                           │                       │make tf-destroy CLOUD=gcp    # Destroy resources

└───────────────────────┘                           └───────────────────────┘

```# Policy evaluation

make policy-tf               # Evaluate Terraform policies

### Data Flowmake policy-k8s              # Evaluate Kubernetes policies



```# Cleanup

Developer → Git → GitHub → CI/CD Pipelinemake clean                   # Remove generated files

                              ↓```

                    ┌─────────┴──────────┐

                    │                    │## Project Structure

                    ▼                    ▼

              Policy Check         Format/Validate```

                    │                    │.

                    └─────────┬──────────┘├── .github/

                              ↓│   ├── workflows/

                        [Pass/Fail]│   │   └── pipeline.yml          # CI/CD pipeline with matrix strategy

                              ││   └── dependabot.yml             # Automated dependency updates

                    ┌─────────┴──────────┐├── argocd/

                    │                    ││   └── application.yaml           # ArgoCD application manifest

                    ▼                    ▼├── infra/

            Infrastructure         Application│   └── terraform/

            (Terraform)           (ArgoCD → K8s)│       ├── aws/                   # AWS-specific Terraform configuration

```│       ├── azure/                 # Azure-specific Terraform configuration

│       ├── gcp/                   # GCP-specific Terraform configuration

### Component Details│       ├── terraform.tfvars.example  # Example variables file

│       ├── backend.tf.example     # Backend configuration examples

| Layer | Purpose | Key Benefits |│       └── modules/

|-------|---------|-------------|│           ├── aws/               # AWS-specific resources

| **Infrastructure (Terraform)** | Provision cloud infrastructure in a vendor-agnostic manner | Clear separation per cloud, consistent patterns, independent deployments |│           ├── azure/             # Azure-specific resources

| **Policy (OPA/Rego)** | Enforce governance and security before deployment | Shift-left security, automated compliance, policy-as-code |│           └── gcp/               # GCP-specific resources

| **CI/CD (GitHub Actions)** | Automate validation across all cloud providers | Parallel testing, early detection, audit trail |├── k8s/

| **Application (Kubernetes)** | Deploy applications using GitOps methodology | Declarative, Git as source of truth, auto-sync, rollback |│   └── app/

│       ├── namespace.yaml         # Namespace definition

---│       ├── deployment.yaml        # Application deployment (production-ready)

│       ├── service.yaml           # Service definition

## Prerequisites│       ├── pdb.yaml              # Pod Disruption Budget

│       └── hpa.yaml              # Horizontal Pod Autoscaler

- [Terraform](https://www.terraform.io/downloads.html) >= 1.6.0├── policies/

- [OPA](https://www.openpolicyagent.org/docs/latest/#1-download-opa) >= 0.50.0│   ├── kubernetes/

- [Conftest](https://www.conftest.dev/install/) >= 0.40.0│   │   └── required-labels.rego   # K8s governance policies

- Cloud provider credentials (AWS, Azure, or GCP)│   └── terraform/

- [kubectl](https://kubernetes.io/docs/tasks/tools/) (for Kubernetes deployment)│       ├── security.rego          # Terraform security policies

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) (for GitOps)│       └── sample-tfplan.json     # Sample plan for testing

├── CONTRIBUTING.md                # Contribution guidelines

---├── LICENSE                        # MIT License

├── Makefile                       # Build automation

## Quick Start└── README.md                      # This file

```

### 1. Configure Cloud Provider

## Cloud Provider Details

Select target cloud (`aws`, `azure`, or `gcp`) and set up credentials:

### AWS

**AWS:**- Creates VPC with DNS support and hostnames enabled

```bash- Deploys subnet in first availability zone

export AWS_ACCESS_KEY_ID="your-access-key"- Applies consistent tagging

export AWS_SECRET_ACCESS_KEY="your-secret-key"

export AWS_DEFAULT_REGION="us-east-1"### Azure

```- Creates Resource Group

- Deploys Virtual Network and Subnet

**Azure:**- Applies consistent tagging

```bash

az login### GCP

```- Creates VPC network (custom mode)

- Deploys subnet with specified CIDR

**GCP:**- Note: GCP networks don't support labels directly

```bash

gcloud auth application-default login## Kubernetes Deployment Features

export GOOGLE_PROJECT="your-project-id"

```The sample application includes production-ready configurations:

- ✅ Resource requests and limits

### 2. Initialize and Deploy Infrastructure- ✅ Liveness and readiness probes

- ✅ Security contexts (non-root, read-only filesystem)

```bash- ✅ Pod Disruption Budget for high availability

# Navigate to target cloud directory (replace 'aws' with 'azure' or 'gcp')- ✅ Horizontal Pod Autoscaler

cd infra/terraform/aws- ✅ Proper labeling for governance



# Initialize and validate## Policy Enforcement

terraform init

terraform validate### Kubernetes Policies

terraform plan -out=tfplan- Required labels validation

terraform show -json tfplan > tfplan.json- Resource limits enforcement

```- Security context requirements

- Health probe requirements

### 3. Evaluate Governance Policies- Read-only filesystem enforcement



**Terraform policies:**### Terraform Policies

```bash- Required tags/labels on all resources

opa eval --fail-defined --format pretty \- Public access restrictions

  --data ../../../policies/terraform \- Encryption requirements

  --input tfplan.json \- Network security validations

  "data.terraform.deny"

```## CI/CD Pipeline



**Kubernetes policies:**The GitHub Actions workflow includes:

```bash- Multi-cloud matrix strategy (tests all three providers)

conftest test ../../../k8s/app -p ../../../policies/kubernetes- Terraform formatting, initialization, and validation

```- Policy evaluation for both Terraform and Kubernetes

- Artifact upload for Terraform plans

### 4. Apply Infrastructure (if policies pass)- Automated dependency updates via Dependabot



```bash## Troubleshooting

terraform apply tfplan

```### Terraform Issues



---**Problem: Provider authentication fails**

```bash

## Using the Makefile# Verify credentials are set correctly

aws sts get-caller-identity  # AWS

```bashaz account show              # Azure

# Show all available commandsgcloud auth list             # GCP

make help```



# Run all checks**Problem: Backend initialization fails**

make all- Ensure you've configured the backend in `backend.tf`

- Check that you have permissions to access the state storage

# Terraform operations (specify CLOUD=aws, azure, or gcp)

make tf-init CLOUD=aws       # Initialize Terraform### Policy Issues

make tf-fmt                  # Format Terraform code

make tf-validate CLOUD=aws   # Validate configuration**Problem: Policy evaluation fails**

make tf-plan CLOUD=aws       # Generate plan for specific cloud```bash

make tf-apply CLOUD=azure    # Apply changes# Validate Rego syntax

make tf-destroy CLOUD=gcp    # Destroy resourcesopa check policies/terraform/security.rego

opa check policies/kubernetes/required-labels.rego

# Policy evaluation

make policy-tf               # Evaluate Terraform policies# Test policies with verbose output

make policy-k8s              # Evaluate Kubernetes policiesopa eval --format pretty \

  --data policies/terraform \

# Cleanup  --input policies/terraform/sample-tfplan.json \

make clean                   # Remove generated files  "data.terraform"

``````



---**Problem: Kubernetes policies fail**

- Ensure all required labels are present

## Project Structure- Check that resource limits are defined

- Verify security contexts are properly configured

```

.## Development

├── .github/

│   ├── labels.yml                 # Repository label definitions### Pre-commit Hooks

│   ├── dependabot.yml             # Automated dependency updates

│   └── workflows/Install pre-commit hooks for automatic validation:

│       ├── pipeline.yml           # CI/CD pipeline with matrix strategy

│       └── labels.yml             # Label sync workflow```bash

├── argocd/pip install pre-commit

│   └── application.yaml           # ArgoCD application manifestpre-commit install

├── infra/```

│   └── terraform/

│       ├── aws/                   # AWS-specific Terraform configurationThis will automatically run:

│       ├── azure/                 # Azure-specific Terraform configuration- Terraform formatting and validation

│       ├── gcp/                   # GCP-specific Terraform configuration- YAML linting

│       ├── terraform.tfvars.example  # Example variables file- Secret detection

│       ├── backend.tf.example     # Backend configuration reference- Trailing whitespace cleanup

│       └── modules/

│           ├── aws/               # AWS networking module### Contributing

│           ├── azure/             # Azure networking module

│           └── gcp/               # GCP networking moduleSee [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

├── k8s/

│   └── app/## Notes

│       ├── namespace.yaml         # Namespace definition

│       ├── deployment.yaml        # Application deployment (production-ready)- This is intentionally provider-neutral at the orchestration level

│       ├── service.yaml           # Service definition- Cloud-specific details are isolated inside provider modules

│       ├── pdb.yaml               # Pod Disruption Budget- Governance controls are codified and enforced before deployment

│       └── hpa.yaml               # Horizontal Pod Autoscaler- The project demonstrates scalability through automated multi-cloud testing

├── policies/

│   ├── kubernetes/## License

│   │   └── required-labels.rego   # K8s governance policies

│   └── terraform/This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

│       ├── security.rego          # Terraform security policies

│       └── sample-tfplan.json     # Sample plan for testing## Acknowledgments

├── .pre-commit-config.yaml        # Pre-commit hook configuration

├── LICENSE                        # MIT LicenseThis implementation demonstrates concepts from the dissertation:

├── Makefile                       # Build automation*"Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines"*

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

1. Choose your target cloud directory (`aws/`, `azure/`, or `gcp/`)
2. Copy `backend.tf.example` to `backend.tf`
3. Edit with your backend-specific settings

| Cloud | Backend | Lock Mechanism |
|-------|---------|----------------|
| AWS | S3 bucket | DynamoDB table |
| Azure | Azure Storage Account | Built-in |
| GCP | Cloud Storage bucket | Built-in |

---

## Kubernetes Deployment

The sample application includes production-ready configurations:

- ✅ Resource requests and limits
- ✅ Liveness and readiness probes
- ✅ Security contexts (non-root, read-only filesystem, drop all capabilities)
- ✅ Pod Disruption Budget for high availability
- ✅ Horizontal Pod Autoscaler (CPU and memory based)
- ✅ Proper labeling for governance compliance
- ✅ Volume mounts for nginx with read-only root filesystem

### Manifests

| File | Kind | Purpose |
|------|------|---------|
| `namespace.yaml` | Namespace | Creates `dissertation` namespace |
| `deployment.yaml` | Deployment | nginx 1.27 with 2 replicas, full security context |
| `service.yaml` | Service | TCP port 80 exposure |
| `hpa.yaml` | HorizontalPodAutoscaler | Auto-scale 2–10 pods (70% CPU, 80% memory) |
| `pdb.yaml` | PodDisruptionBudget | Minimum 1 pod always available |

### Scalability Features

1. **Horizontal Scaling**: HPA automatically scales pods based on CPU/Memory
2. **High Availability**: PDB ensures minimum availability during disruptions
3. **Resource Management**: Defined requests/limits enable efficient scheduling

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
| Network Security | AWS VPCs should have Flow Logs enabled; GCP firewalls should not allow unrestricted 0.0.0.0/0 ingress |

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
1. **Terraform Format Check** — Ensures code consistency
2. **Terraform Init & Validate** — Verifies syntax (`-backend=false` for CI)
3. **Terraform Plan** — Generates plans per cloud provider
4. **OPA Policy Evaluation** — Runs against both the sample plan and the real plan
5. **Conftest Kubernetes Policy Evaluation** — Validates K8s manifests
6. **Artifact Upload** — Saves Terraform plans for review (30-day retention)

### GitHub Repository Secrets

Configure these in **Settings → Secrets and variables → Actions → New repository secret**:

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

1. Update `argocd/application.yaml` with your repository URL:
   ```yaml
   source:
     repoURL: https://github.com/YOUR_USERNAME/dissertation
   ```

2. Apply:
   ```bash
   kubectl apply -f argocd/application.yaml
   ```

3. Verify:
   ```bash
   kubectl get application -n argocd
   kubectl get all -n dissertation
   ```

The ArgoCD application is configured with:
- **Automated sync** with self-healing and pruning
- **Auto namespace creation** (`CreateNamespace=true`)
- **Retry policy** with exponential backoff (5 attempts, max 3 minutes)

---

## Pre-commit Hooks

### Setup

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files   # Test on all files
```

### What Gets Checked

- Trailing whitespace & end-of-file fixes
- YAML syntax validation
- Large file detection
- Merge conflict markers
- Private key detection
- Terraform formatting & validation
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

1. **Policy Enforcement** — Automated validation before any deployment
2. **Security Contexts** — Non-root containers, read-only filesystems, dropped capabilities
3. **Network Security** — HTTPS-only, no public access by default, VPC Flow Logs
4. **Secret Management** — All credentials stored in GitHub Secrets, never committed
5. **Dependency Scanning** — Dependabot monitors for outdated dependencies
6. **Pre-commit Hooks** — Private key detection, secret scanning before commits

---

## Best Practices

1. **Always create feature branches** — Don't push directly to main
2. **Wait for CI checks** before merging pull requests
3. **Review policy violations** carefully — they're there for a reason
4. **Keep dependencies updated** — Merge Dependabot PRs regularly
5. **Monitor ArgoCD** — Ensure applications stay in sync
6. **Use pre-commit hooks** — Catch issues before they reach CI

---

## Notes

- This is intentionally provider-neutral at the orchestration level
- Cloud-specific details are isolated inside provider modules
- Governance controls are codified and enforced before deployment
- The project demonstrates scalability through automated multi-cloud testing

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This implementation demonstrates concepts from the dissertation:
*"Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines"*
