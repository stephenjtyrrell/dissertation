# Dissertation Implementation: Vendor-Agnostic Multi-Cloud Pipeline# Dissertation Implementation: Vendor-Agnostic Multi-Cloud Pipeline# Dissertation Implementation: Vendor-Agnostic Multi-Cloud Pipeline



This repository provides a practical implementation for the dissertation topic:



> **Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines**This repository provides a practical implementation for the dissertation topic:This repository provides a practical implementation for the dissertation topic:



---



## Table of Contents> **Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines**`Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines`



- [What is Included](#what-is-included)

- [Architecture](#architecture)

- [Prerequisites](#prerequisites)---## What is included

- [Quick Start](#quick-start)

- [Using the Makefile](#using-the-makefile)

- [Project Structure](#project-structure)

- [Terraform Infrastructure](#terraform-infrastructure)## Table of Contents- **`infra/terraform/`**: Multi-cloud Infrastructure as Code (AWS, Azure, GCP) with a consistent interface

- [Kubernetes Deployment](#kubernetes-deployment)

- [Policy Enforcement (OPA/Rego)](#policy-enforcement-oparego)- **`policies/`**: OPA/Rego governance policies for Terraform and Kubernetes

- [CI/CD Pipeline](#cicd-pipeline)

- [ArgoCD / GitOps Setup](#argocd--gitops-setup)- [What is Included](#what-is-included)- **`.github/workflows/pipeline.yml`**: CI pipeline for IaC validation and policy checks across all cloud providers

- [Pre-commit Hooks](#pre-commit-hooks)

- [Troubleshooting](#troubleshooting)- [Architecture](#architecture)- **`k8s/app/`**: Production-ready Kubernetes workload with security best practices, deployed through GitOps

- [License](#license)

- [Prerequisites](#prerequisites)- **`argocd/application.yaml`**: Argo CD app manifest for GitOps delivery

---

- [Quick Start](#quick-start)

## What is Included

- [Using the Makefile](#using-the-makefile)## Architecture

| Component | Path | Description |

|-----------|------|-------------|- [Project Structure](#project-structure)

| Terraform IaC | `infra/terraform/` | Multi-cloud infrastructure (AWS, Azure, GCP) with consistent interface |

| OPA Policies | `policies/` | Governance policies for Terraform and Kubernetes |- [Terraform Infrastructure](#terraform-infrastructure)This project demonstrates vendor-agnostic multi-cloud deployment through:

| CI/CD Pipeline | `.github/workflows/pipeline.yml` | GitHub Actions for IaC validation and policy checks |

| Kubernetes App | `k8s/app/` | Production-ready workload with security best practices |- [Kubernetes Deployment](#kubernetes-deployment)- **Abstraction Layer**: Consistent Terraform interface regardless of cloud provider

| ArgoCD Manifest | `argocd/application.yaml` | GitOps delivery via Argo CD |

- [Policy Enforcement (OPA/Rego)](#policy-enforcement-oparego)- **Policy-as-Code**: Automated governance enforcement with OPA

---

- [CI/CD Pipeline](#cicd-pipeline)- **GitOps**: Declarative Kubernetes deployments via ArgoCD

## Architecture

- [ArgoCD / GitOps Setup](#argocd--gitops-setup)- **CI/CD**: Automated validation and testing for all three cloud providers

This project demonstrates vendor-agnostic multi-cloud deployment through:

- [Pre-commit Hooks](#pre-commit-hooks)

- **Abstraction Layer**: Consistent Terraform interface regardless of cloud provider

- **Policy-as-Code**: Automated governance enforcement with OPA- [Troubleshooting](#troubleshooting)## Prerequisites

- **GitOps**: Declarative Kubernetes deployments via ArgoCD

- **CI/CD**: Automated validation and testing for all three cloud providers- [License](#license)



```- [Terraform](https://www.terraform.io/downloads.html) >= 1.6.0

┌─────────────────────────────────────────────────────────────────────────┐

│                          Developer Workflow                              │---- [OPA](https://www.openpolicyagent.org/docs/latest/#1-download-opa) >= 0.50.0

│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐         │

│  │   Code   │───▶│   Git    │───▶│  GitHub  │───▶│   CI/CD  │         │- [Conftest](https://www.conftest.dev/install/) >= 0.40.0

│  │  Changes │    │  Commit  │    │   Push   │    │ Pipeline │         │

│  └──────────┘    └──────────┘    └──────────┘    └─────┬────┘         │## What is Included- Cloud provider credentials (AWS, Azure, or GCP)

└──────────────────────────────────────────────────────────┼──────────────┘

                                                            │- [kubectl](https://kubernetes.io/docs/tasks/tools/) (for Kubernetes deployment)

                    ┌───────────────────────────────────────┼───────────────┐

                    │          CI/CD Pipeline (GitHub Actions)              │| Component | Path | Description |- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) (for GitOps)

                    │                                                        │

                    │  ┌──────────────────────────────────────────────┐    │|-----------|------|-------------|

                    │  │  1. Terraform Format & Validation            │    │

                    │  └──────────────┬───────────────────────────────┘    │| Terraform IaC | `infra/terraform/` | Multi-cloud infrastructure (AWS, Azure, GCP) with consistent interface |## Quick start

                    │                 │                                     │

                    │  ┌──────────────▼───────────────────────────────┐    │| OPA Policies | `policies/` | Governance policies for Terraform and Kubernetes |

                    │  │  2. Multi-Cloud Plan Generation              │    │

                    │  │     (AWS, Azure, GCP in parallel)            │    │| CI/CD Pipeline | `.github/workflows/pipeline.yml` | GitHub Actions for IaC validation and policy checks |### 1. Configure Cloud Provider

                    │  └──────────────┬───────────────────────────────┘    │

                    │                 │                                     │| Kubernetes App | `k8s/app/` | Production-ready workload with security best practices |

                    │  ┌──────────────▼───────────────────────────────┐    │

                    │  │  3. Policy Evaluation (OPA)                  │    │| ArgoCD Manifest | `argocd/application.yaml` | GitOps delivery via Argo CD |Select target cloud (`aws`, `azure`, or `gcp`) and set up credentials:

                    │  │     - Terraform Security Policies            │    │

                    │  │     - Kubernetes Governance Policies         │    │

                    │  └──────────────┬───────────────────────────────┘    │

                    │                 │                                     │---**AWS:**

                    │                 │ [Policies Pass]                     │

                    └─────────────────┼─────────────────────────────────────┘```bash

                                      │

            ┌─────────────────────────┴─────────────────────────┐## Architectureexport AWS_ACCESS_KEY_ID="your-access-key"

            │                                                     │

            ▼                                                     ▼export AWS_SECRET_ACCESS_KEY="your-secret-key"

┌───────────────────────┐                           ┌───────────────────────┐

│  Infrastructure Layer │                           │   Application Layer   │This project demonstrates vendor-agnostic multi-cloud deployment through:export AWS_DEFAULT_REGION="us-east-1"

│   (Terraform)         │                           │   (Kubernetes)        │

│                       │                           │                       │- **Abstraction Layer**: Consistent Terraform interface regardless of cloud provider```

│  ┌─────────────────┐  │                           │  ┌─────────────────┐  │

│  │  Cloud Provider │  │                           │  │   GitOps Sync   │  │- **Policy-as-Code**: Automated governance enforcement with OPA

│  │   Selection     │  │                           │  │   (ArgoCD)      │  │

│  │   (aws/azure/   │  │                           │  └────────┬────────┘  │- **GitOps**: Declarative Kubernetes deployments via ArgoCD**Azure:**

│  │     gcp)        │  │                           │           │           │

│  └────────┬────────┘  │                           │  ┌────────▼────────┐  │- **CI/CD**: Automated validation and testing for all three cloud providers```bash

│           │           │                           │  │  Kubernetes     │  │

│  ┌────────▼────────┐  │                           │  │  Manifests      │  │az login

│  │  Module Routing │  │                           │  │  - Namespace    │  │

│  │  (Per-cloud     │  │                           │  │  - Deployment   │  │``````

│  │   directories)  │  │                           │  │  - Service      │  │

│  └────────┬────────┘  │                           │  │  - HPA          │  │┌─────────────────────────────────────────────────────────────────────────┐

│           │           │                           │  │  - PDB          │  │

│  ┌────────▼────────┐  │                           │  └─────────────────┘  ││                          Developer Workflow                              │**GCP:**

│  │ Provider Module │  │                           │                       │

│  │  aws/azure/gcp  │  │                           │                       ││  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐         │```bash

│  └────────┬────────┘  │                           │                       │

│           │           │                           │                       ││  │   Code   │───▶│   Git    │───▶│  GitHub  │───▶│   CI/CD  │         │gcloud auth application-default login

│  ┌────────▼────────┐  │                           │                       │

│  │  Infrastructure │  │                           │                       ││  │  Changes │    │  Commit  │    │   Push   │    │ Pipeline │         │export GOOGLE_PROJECT="your-project-id"

│  │   Resources     │  │                           │                       │

│  │  - VPC/VNet     │  │                           │                       ││  └──────────┘    └──────────┘    └──────────┘    └─────┬────┘         │```

│  │  - Subnets      │  │                           │                       │

│  │  - Tags/Labels  │  │                           │                       │└──────────────────────────────────────────────────────────┼──────────────┘

│  └─────────────────┘  │                           │                       │

└───────────────────────┘                           └───────────────────────┘                                                            │### 2. Initialize and Deploy Infrastructure

```

                    ┌───────────────────────────────────────┼───────────────┐

### Data Flow

                    │          CI/CD Pipeline (GitHub Actions)              │```bash

```

Developer → Git → GitHub → CI/CD Pipeline                    │                                                        │# Copy and customize terraform variables for your target cloud

                              ↓

                    ┌─────────┴──────────┐                    │  ┌──────────────────────────────────────────────┐    │# For AWS:

                    │                    │

                    ▼                    ▼                    │  │  1. Terraform Format & Validation            │    │cp infra/terraform/terraform.tfvars.example infra/terraform/aws/terraform.tfvars

              Policy Check         Format/Validate

                    │                    │                    │  └──────────────┬───────────────────────────────┘    │

                    └─────────┬──────────┘

                              ↓                    │                 │                                     │# Initialize and validate (replace 'aws' with 'azure' or 'gcp' as needed)

                        [Pass/Fail]

                              │                    │  ┌──────────────▼───────────────────────────────┐    │cd infra/terraform/aws

                    ┌─────────┴──────────┐

                    │                    │                    │  │  2. Multi-Cloud Plan Generation              │    │terraform init

                    ▼                    ▼

            Infrastructure         Application                    │  │     (AWS, Azure, GCP in parallel)            │    │terraform validate

            (Terraform)           (ArgoCD → K8s)

```                    │  └──────────────┬───────────────────────────────┘    │terraform plan -out=tfplan



### Component Details                    │                 │                                     │terraform show -json tfplan > tfplan.json



| Layer | Purpose | Key Benefits |                    │  ┌──────────────▼───────────────────────────────┐    │```

|-------|---------|--------------|

| **Infrastructure (Terraform)** | Provision cloud infrastructure in a vendor-agnostic manner | Clear separation per cloud, consistent patterns, independent deployments |                    │  │  3. Policy Evaluation (OPA)                  │    │

| **Policy (OPA/Rego)** | Enforce governance and security before deployment | Shift-left security, automated compliance, policy-as-code |

| **CI/CD (GitHub Actions)** | Automate validation across all cloud providers | Parallel testing, early detection, audit trail |                    │  │     - Terraform Security Policies            │    │### 3. Evaluate Governance Policies

| **Application (Kubernetes)** | Deploy applications using GitOps methodology | Declarative, Git as source of truth, auto-sync, rollback |

                    │  │     - Kubernetes Governance Policies         │    │

---

                    │  └──────────────┬───────────────────────────────┘    │**Terraform policies:**

## Prerequisites

                    │                 │                                     │```bash

- [Terraform](https://www.terraform.io/downloads.html) >= 1.6.0

- [OPA](https://www.openpolicyagent.org/docs/latest/#1-download-opa) >= 0.50.0                    │                 │ [Policies Pass]                     │opa eval --fail-defined --format pretty \

- [Conftest](https://www.conftest.dev/install/) >= 0.40.0

- Cloud provider credentials (AWS, Azure, or GCP)                    └─────────────────┼─────────────────────────────────────┘  --data ../../../policies/terraform \

- [kubectl](https://kubernetes.io/docs/tasks/tools/) (for Kubernetes deployment)

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) (for GitOps)                                      │  --input tfplan.json \



---            ┌─────────────────────────┴─────────────────────────┐  "data.terraform.deny"



## Quick Start            │                                                     │```



### 1. Configure Cloud Provider            ▼                                                     ▼



Select target cloud (`aws`, `azure`, or `gcp`) and set up credentials:┌───────────────────────┐                           ┌───────────────────────┐**Kubernetes policies:**



**AWS:**│  Infrastructure Layer │                           │   Application Layer   │```bash



```bash│   (Terraform)         │                           │   (Kubernetes)        │conftest test ../../../k8s/app -p ../../../policies/kubernetes

export AWS_ACCESS_KEY_ID="your-access-key"

export AWS_SECRET_ACCESS_KEY="your-secret-key"│                       │                           │                       │```

export AWS_DEFAULT_REGION="us-east-1"

```│  ┌─────────────────┐  │                           │  ┌─────────────────┐  │



**Azure:**│  │  Cloud Provider │  │                           │  │   GitOps Sync   │  │### 4. Apply Infrastructure (if policies pass)



```bash│  │   Selection     │  │                           │  │   (ArgoCD)      │  │

az login

```│  │   (aws/azure/   │  │                           │  └────────┬────────┘  │```bash



**GCP:**│  │     gcp)        │  │                           │           │           │terraform apply



```bash│  └────────┬────────┘  │                           │  ┌────────▼────────┐  │```

gcloud auth application-default login

export GOOGLE_PROJECT="your-project-id"│           │           │                           │  │  Kubernetes     │  │

```

│  ┌────────▼────────┐  │                           │  │  Manifests      │  │## Using the Makefile

### 2. Initialize and Deploy Infrastructure

│  │  Module Routing │  │                           │  │  - Namespace    │  │

```bash

# Navigate to target cloud directory (replace 'aws' with 'azure' or 'gcp')│  │  (Per-cloud     │  │                           │  │  - Deployment   │  │The project includes a comprehensive Makefile for common tasks:

cd infra/terraform/aws

│  │   directories)  │  │                           │  │  - Service      │  │

# Initialize and validate

terraform init│  └────────┬────────┘  │                           │  │  - HPA          │  │```bash

terraform validate

terraform plan -out=tfplan│           │           │                           │  │  - PDB          │  │# Show all available commands

terraform show -json tfplan > tfplan.json

```│  ┌────────▼────────┐  │                           │  └─────────────────┘  │make help



### 3. Evaluate Governance Policies│  │ Provider Module │  │                           │                       │



**Terraform policies:**│  │  aws/azure/gcp  │  │                           │                       │# Run all checks



```bash│  └────────┬────────┘  │                           │                       │make all

opa eval --fail-defined --format pretty \

  --data ../../../policies/terraform \│           │           │                           │                       │

  --input tfplan.json \

  "data.terraform.deny"│  ┌────────▼────────┐  │                           │                       │# Terraform operations (specify CLOUD=aws, azure, or gcp)

```

│  │  Infrastructure │  │                           │                       │make tf-init CLOUD=aws       # Initialize Terraform

**Kubernetes policies:**

│  │   Resources     │  │                           │                       │make tf-fmt                  # Format Terraform code

```bash

conftest test ../../../k8s/app -p ../../../policies/kubernetes│  │  - VPC/VNet     │  │                           │                       │make tf-validate CLOUD=aws   # Validate configuration

```

│  │  - Subnets      │  │                           │                       │make tf-plan CLOUD=aws       # Generate plan for specific cloud

### 4. Apply Infrastructure (if policies pass)

│  │  - Tags/Labels  │  │                           │                       │make tf-apply CLOUD=azure    # Apply changes

```bash

terraform apply tfplan│  └─────────────────┘  │                           │                       │make tf-destroy CLOUD=gcp    # Destroy resources

```

└───────────────────────┘                           └───────────────────────┘

---

```# Policy evaluation

## Using the Makefile

make policy-tf               # Evaluate Terraform policies

```bash

# Show all available commands### Data Flowmake policy-k8s              # Evaluate Kubernetes policies

make help



# Run all checks

make all```# Cleanup



# Terraform operations (specify CLOUD=aws, azure, or gcp)Developer → Git → GitHub → CI/CD Pipelinemake clean                   # Remove generated files

make tf-init CLOUD=aws       # Initialize Terraform

make tf-fmt                  # Format Terraform code                              ↓```

make tf-validate CLOUD=aws   # Validate configuration

make tf-plan CLOUD=aws       # Generate plan for specific cloud                    ┌─────────┴──────────┐

make tf-apply CLOUD=azure    # Apply changes

make tf-destroy CLOUD=gcp    # Destroy resources                    │                    │## Project Structure



# Policy evaluation                    ▼                    ▼

make policy-tf               # Evaluate Terraform policies

make policy-k8s              # Evaluate Kubernetes policies              Policy Check         Format/Validate```



# Cleanup                    │                    │.

make clean                   # Remove generated files

```                    └─────────┬──────────┘├── .github/



---                              ↓│   ├── workflows/



## Project Structure                        [Pass/Fail]│   │   └── pipeline.yml          # CI/CD pipeline with matrix strategy



```                              ││   └── dependabot.yml             # Automated dependency updates

.

├── .github/                    ┌─────────┴──────────┐├── argocd/

│   ├── labels.yml                 # Repository label definitions

│   ├── dependabot.yml             # Automated dependency updates                    │                    ││   └── application.yaml           # ArgoCD application manifest

│   └── workflows/

│       ├── pipeline.yml           # CI/CD pipeline with matrix strategy                    ▼                    ▼├── infra/

│       └── labels.yml             # Label sync workflow

├── argocd/            Infrastructure         Application│   └── terraform/

│   └── application.yaml           # ArgoCD application manifest

├── infra/            (Terraform)           (ArgoCD → K8s)│       ├── aws/                   # AWS-specific Terraform configuration

│   └── terraform/

│       ├── aws/                   # AWS-specific Terraform configuration```│       ├── azure/                 # Azure-specific Terraform configuration

│       ├── azure/                 # Azure-specific Terraform configuration

│       ├── gcp/                   # GCP-specific Terraform configuration│       ├── gcp/                   # GCP-specific Terraform configuration

│       ├── terraform.tfvars.example  # Example variables file

│       ├── backend.tf.example     # Backend configuration reference### Component Details│       ├── terraform.tfvars.example  # Example variables file

│       └── modules/

│           ├── aws/               # AWS networking module│       ├── backend.tf.example     # Backend configuration examples

│           ├── azure/             # Azure networking module

│           └── gcp/               # GCP networking module| Layer | Purpose | Key Benefits |│       └── modules/

├── k8s/

│   └── app/|-------|---------|-------------|│           ├── aws/               # AWS-specific resources

│       ├── namespace.yaml         # Namespace definition

│       ├── deployment.yaml        # Application deployment (production-ready)| **Infrastructure (Terraform)** | Provision cloud infrastructure in a vendor-agnostic manner | Clear separation per cloud, consistent patterns, independent deployments |│           ├── azure/             # Azure-specific resources

│       ├── service.yaml           # Service definition

│       ├── pdb.yaml               # Pod Disruption Budget| **Policy (OPA/Rego)** | Enforce governance and security before deployment | Shift-left security, automated compliance, policy-as-code |│           └── gcp/               # GCP-specific resources

│       └── hpa.yaml               # Horizontal Pod Autoscaler

├── policies/| **CI/CD (GitHub Actions)** | Automate validation across all cloud providers | Parallel testing, early detection, audit trail |├── k8s/

│   ├── kubernetes/

│   │   └── required-labels.rego   # K8s governance policies| **Application (Kubernetes)** | Deploy applications using GitOps methodology | Declarative, Git as source of truth, auto-sync, rollback |│   └── app/

│   └── terraform/

│       ├── security.rego          # Terraform security policies│       ├── namespace.yaml         # Namespace definition

│       └── sample-tfplan.json     # Sample plan for testing

├── .pre-commit-config.yaml        # Pre-commit hook configuration---│       ├── deployment.yaml        # Application deployment (production-ready)

├── LICENSE                        # MIT License

├── Makefile                       # Build automation│       ├── service.yaml           # Service definition

└── README.md                      # This file

```## Prerequisites│       ├── pdb.yaml              # Pod Disruption Budget



---│       └── hpa.yaml              # Horizontal Pod Autoscaler



## Terraform Infrastructure- [Terraform](https://www.terraform.io/downloads.html) >= 1.6.0├── policies/



### Directory Layout- [OPA](https://www.openpolicyagent.org/docs/latest/#1-download-opa) >= 0.50.0│   ├── kubernetes/



Each cloud provider has its own isolated directory with independent provider configuration, state, and variables. This avoids cross-cloud authentication issues and allows independent deployments.- [Conftest](https://www.conftest.dev/install/) >= 0.40.0│   │   └── required-labels.rego   # K8s governance policies



```- Cloud provider credentials (AWS, Azure, or GCP)│   └── terraform/

infra/terraform/

├── aws/           # AWS-specific configuration- [kubectl](https://kubernetes.io/docs/tasks/tools/) (for Kubernetes deployment)│       ├── security.rego          # Terraform security policies

├── azure/         # Azure-specific configuration

├── gcp/           # GCP-specific configuration- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) (for GitOps)│       └── sample-tfplan.json     # Sample plan for testing

└── modules/       # Cloud provider modules

    ├── aws/├── CONTRIBUTING.md                # Contribution guidelines

    ├── azure/

    └── gcp/---├── LICENSE                        # MIT License

```

├── Makefile                       # Build automation

### Cloud Provider Details

## Quick Start└── README.md                      # This file

#### AWS Module

```

**Resources created:**

### 1. Configure Cloud Provider

- VPC with DNS support and hostnames enabled

- Subnet in the first availability zone## Cloud Provider Details

- VPC Flow Logs for network traffic monitoring

- CloudWatch Log Group for flow log storageSelect target cloud (`aws`, `azure`, or `gcp`) and set up credentials:

- IAM role and policy for VPC Flow Logs

- All resources tagged according to governance requirements### AWS



```hcl**AWS:**- Creates VPC with DNS support and hostnames enabled

module "aws" {

  source            = "../modules/aws"```bash- Deploys subnet in first availability zone

  name_prefix       = "my-project-dev"

  cidr_block        = "10.42.0.0/16"export AWS_ACCESS_KEY_ID="your-access-key"- Applies consistent tagging

  subnet_cidr_block = "10.42.1.0/24"

  tags = {export AWS_SECRET_ACCESS_KEY="your-secret-key"

    owner       = "platform-team"

    cost_center = "cc-001"export AWS_DEFAULT_REGION="us-east-1"### Azure

    compliance  = "baseline"

  }```- Creates Resource Group

}

```- Deploys Virtual Network and Subnet



| Input | Description | Type |**Azure:**- Applies consistent tagging

|-------|-------------|------|

| `name_prefix` | Prefix for resource names | `string` |```bash

| `cidr_block` | VPC CIDR block | `string` |

| `subnet_cidr_block` | Subnet CIDR block | `string` |az login### GCP

| `tags` | Tags to apply to all resources | `map(string)` |

```- Creates VPC network (custom mode)

**Requirements:** Terraform >= 1.6.0, AWS provider ~> 6.31

- Deploys subnet with specified CIDR

#### Azure Module

**GCP:**- Note: GCP networks don't support labels directly

**Resources created:**

```bash

- Resource Group

- Virtual Networkgcloud auth application-default login## Kubernetes Deployment Features

- Subnet

- All resources tagged according to governance requirementsexport GOOGLE_PROJECT="your-project-id"



```hcl```The sample application includes production-ready configurations:

module "azure" {

  source            = "../modules/azure"- ✅ Resource requests and limits

  name_prefix       = "my-project-dev"

  location          = "eastus"### 2. Initialize and Deploy Infrastructure- ✅ Liveness and readiness probes

  cidr_block        = "10.42.0.0/16"

  subnet_cidr_block = "10.42.1.0/24"- ✅ Security contexts (non-root, read-only filesystem)

  tags = {

    owner       = "platform-team"```bash- ✅ Pod Disruption Budget for high availability

    cost_center = "cc-001"

    compliance  = "baseline"# Navigate to target cloud directory (replace 'aws' with 'azure' or 'gcp')- ✅ Horizontal Pod Autoscaler

  }

}cd infra/terraform/aws- ✅ Proper labeling for governance

```



| Input | Description | Type |

|-------|-------------|------|# Initialize and validate## Policy Enforcement

| `name_prefix` | Prefix for resource names | `string` |

| `location` | Azure region location | `string` |terraform init

| `cidr_block` | VNet CIDR block | `string` |

| `subnet_cidr_block` | Subnet CIDR block | `string` |terraform validate### Kubernetes Policies

| `tags` | Tags to apply to all resources | `map(string)` |

terraform plan -out=tfplan- Required labels validation

**Requirements:** Terraform >= 1.6.0, AzureRM provider ~> 4.58

terraform show -json tfplan > tfplan.json- Resource limits enforcement

#### GCP Module

```- Security context requirements

**Resources created:**

- Health probe requirements

- VPC Network (custom mode, no auto-created subnets)

- Subnet with specified CIDR range### 3. Evaluate Governance Policies- Read-only filesystem enforcement



> **Note:** GCP Compute networks and subnetworks do not support labels directly.



```hcl**Terraform policies:**### Terraform Policies

module "gcp" {

  source            = "../modules/gcp"```bash- Required tags/labels on all resources

  name_prefix       = "my-project-dev"

  region            = "us-central1"opa eval --fail-defined --format pretty \- Public access restrictions

  cidr_block        = "10.42.0.0/16"

  subnet_cidr_block = "10.42.1.0/24"  --data ../../../policies/terraform \- Encryption requirements

}

```  --input tfplan.json \- Network security validations



| Input | Description | Type |  "data.terraform.deny"

|-------|-------------|------|

| `name_prefix` | Prefix for resource names | `string` |```## CI/CD Pipeline

| `region` | GCP region | `string` |

| `cidr_block` | VPC CIDR block (kept for interface consistency) | `string` |

| `subnet_cidr_block` | Subnet CIDR block | `string` |

**Kubernetes policies:**The GitHub Actions workflow includes:

**Requirements:** Terraform >= 1.6.0, Google provider ~> 7.18

```bash- Multi-cloud matrix strategy (tests all three providers)

### Backend Configuration

conftest test ../../../k8s/app -p ../../../policies/kubernetes- Terraform formatting, initialization, and validation

Each cloud directory has a `backend.tf.example` file. To use a remote backend:

```- Policy evaluation for both Terraform and Kubernetes

1. Choose your target cloud directory (`aws/`, `azure/`, or `gcp/`)

2. Copy `backend.tf.example` to `backend.tf`- Artifact upload for Terraform plans

3. Edit with your backend-specific settings

### 4. Apply Infrastructure (if policies pass)- Automated dependency updates via Dependabot

| Cloud | Backend | Lock Mechanism |

|-------|---------|----------------|

| AWS | S3 bucket | DynamoDB table |

| Azure | Azure Storage Account | Built-in |```bash## Troubleshooting

| GCP | Cloud Storage bucket | Built-in |

terraform apply tfplan

---

```### Terraform Issues

## Kubernetes Deployment



The sample application includes production-ready configurations:

---**Problem: Provider authentication fails**

- ✅ Resource requests and limits

- ✅ Liveness and readiness probes```bash

- ✅ Security contexts (non-root, read-only filesystem, drop all capabilities)

- ✅ Pod Disruption Budget for high availability## Using the Makefile# Verify credentials are set correctly

- ✅ Horizontal Pod Autoscaler (CPU and memory based)

- ✅ Proper labeling for governance complianceaws sts get-caller-identity  # AWS

- ✅ Volume mounts for nginx with read-only root filesystem

```bashaz account show              # Azure

### Manifests

# Show all available commandsgcloud auth list             # GCP

| File | Kind | Purpose |

|------|------|---------|make help```

| `namespace.yaml` | Namespace | Creates `dissertation` namespace |

| `deployment.yaml` | Deployment | nginx 1.27 with 2 replicas, full security context |

| `service.yaml` | Service | TCP port 80 exposure |

| `hpa.yaml` | HorizontalPodAutoscaler | Auto-scale 2–10 pods (70% CPU, 80% memory) |# Run all checks**Problem: Backend initialization fails**

| `pdb.yaml` | PodDisruptionBudget | Minimum 1 pod always available |

make all- Ensure you've configured the backend in `backend.tf`

### Scalability Features

- Check that you have permissions to access the state storage

1. **Horizontal Scaling**: HPA automatically scales pods based on CPU/Memory

2. **High Availability**: PDB ensures minimum availability during disruptions# Terraform operations (specify CLOUD=aws, azure, or gcp)

3. **Resource Management**: Defined requests/limits enable efficient scheduling

make tf-init CLOUD=aws       # Initialize Terraform### Policy Issues

---

make tf-fmt                  # Format Terraform code

## Policy Enforcement (OPA/Rego)

make tf-validate CLOUD=aws   # Validate configuration**Problem: Policy evaluation fails**

### Kubernetes Policies

make tf-plan CLOUD=aws       # Generate plan for specific cloud```bash

**Location:** `policies/kubernetes/required-labels.rego`

make tf-apply CLOUD=azure    # Apply changes# Validate Rego syntax

| Rule | Description |

|------|-------------|make tf-destroy CLOUD=gcp    # Destroy resourcesopa check policies/terraform/security.rego

| Required Labels | `app.kubernetes.io/name`, `app.kubernetes.io/part-of`, `owner`, `compliance` |

| Resource Limits | All containers must define `resources.requests` and `resources.limits` |opa check policies/kubernetes/required-labels.rego

| Security Context | Must be defined; `privileged` must not be true; `readOnlyRootFilesystem` should be true |

| Health Probes | All containers should define `livenessProbe` and `readinessProbe` |# Policy evaluation



**Test locally:**make policy-tf               # Evaluate Terraform policies# Test policies with verbose output



```bashmake policy-k8s              # Evaluate Kubernetes policiesopa eval --format pretty \

conftest test k8s/app -p policies/kubernetes

```  --data policies/terraform \



### Terraform Policies# Cleanup  --input policies/terraform/sample-tfplan.json \



**Location:** `policies/terraform/security.rego`make clean                   # Remove generated files  "data.terraform"



| Rule | Description |``````

|------|-------------|

| Required Tags | `owner`, `cost_center`, `compliance`, `project`, `environment`, `managed_by` |

| Storage Security | S3/Azure Storage/GCS must not allow public access; S3 must have encryption; Azure must enable HTTPS only |

| Network Security | AWS VPCs should have Flow Logs enabled; GCP firewalls should not allow unrestricted 0.0.0.0/0 ingress |---**Problem: Kubernetes policies fail**



> **Note:** Certain resource types that don't support tags/labels are automatically exempted (e.g., `aws_iam_role_policy`, `azurerm_subnet`, `google_compute_network`).- Ensure all required labels are present



**Test locally:**## Project Structure- Check that resource limits are defined



```bash- Verify security contexts are properly configured

# Against sample plan

opa eval --fail-defined --format pretty \```

  --data policies/terraform \

  --input policies/terraform/sample-tfplan.json \.## Development

  "data.terraform.deny"

├── .github/

# Against a real plan

terraform -chdir=infra/terraform/aws plan -out=tfplan│   ├── labels.yml                 # Repository label definitions### Pre-commit Hooks

terraform -chdir=infra/terraform/aws show -json tfplan > tfplan.json

opa eval --fail-defined --format pretty \│   ├── dependabot.yml             # Automated dependency updates

  --data policies/terraform \

  --input tfplan.json \│   └── workflows/Install pre-commit hooks for automatic validation:

  "data.terraform.deny"

```│       ├── pipeline.yml           # CI/CD pipeline with matrix strategy



### Adding New Policies│       └── labels.yml             # Label sync workflow```bash



**Kubernetes:**├── argocd/pip install pre-commit



```rego│   └── application.yaml           # ArgoCD application manifestpre-commit install

deny[msg] {

  # Your condition logic├── infra/```

  msg := sprintf("Your error message: %v", [variables])

}│   └── terraform/

```

│       ├── aws/                   # AWS-specific Terraform configurationThis will automatically run:

**Terraform:**

│       ├── azure/                 # Azure-specific Terraform configuration- Terraform formatting and validation

```rego

deny contains msg if {│       ├── gcp/                   # GCP-specific Terraform configuration- YAML linting

  some rc in input.resource_changes

  # Your condition logic│       ├── terraform.tfvars.example  # Example variables file- Secret detection

  msg := sprintf("Your error message: %v", [variables])

}│       ├── backend.tf.example     # Backend configuration reference- Trailing whitespace cleanup

```

│       └── modules/

---

│           ├── aws/               # AWS networking module### Contributing

## CI/CD Pipeline

│           ├── azure/             # Azure networking module

### Overview

│           └── gcp/               # GCP networking moduleSee [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

The GitHub Actions workflow (`.github/workflows/pipeline.yml`) runs on every push to `main` and on all pull requests. It uses a matrix strategy to test all three cloud providers in parallel.

├── k8s/

**Pipeline stages:**

│   └── app/## Notes

1. **Terraform Format Check** — Ensures code consistency

2. **Terraform Init & Validate** — Verifies syntax (`-backend=false` for CI)│       ├── namespace.yaml         # Namespace definition

3. **Terraform Plan** — Generates plans per cloud provider

4. **OPA Policy Evaluation** — Runs against both the sample plan and the real plan│       ├── deployment.yaml        # Application deployment (production-ready)- This is intentionally provider-neutral at the orchestration level

5. **Conftest Kubernetes Policy Evaluation** — Validates K8s manifests

6. **Artifact Upload** — Saves Terraform plans for review (30-day retention)│       ├── service.yaml           # Service definition- Cloud-specific details are isolated inside provider modules



### GitHub Repository Secrets│       ├── pdb.yaml               # Pod Disruption Budget- Governance controls are codified and enforced before deployment



Configure these in **Settings → Secrets and variables → Actions → New repository secret**:│       └── hpa.yaml               # Horizontal Pod Autoscaler- The project demonstrates scalability through automated multi-cloud testing



#### AWS├── policies/



```│   ├── kubernetes/## License

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY│   │   └── required-labels.rego   # K8s governance policies

AWS_SESSION_TOKEN       (optional)

AWS_REGION              (optional, defaults to us-east-1)│   └── terraform/This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```

│       ├── security.rego          # Terraform security policies

#### Azure

│       └── sample-tfplan.json     # Sample plan for testing## Acknowledgments

```

ARM_CLIENT_ID├── .pre-commit-config.yaml        # Pre-commit hook configuration

ARM_CLIENT_SECRET

ARM_SUBSCRIPTION_ID├── LICENSE                        # MIT LicenseThis implementation demonstrates concepts from the dissertation:

ARM_TENANT_ID

```├── Makefile                       # Build automation*"Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines"*



To generate Azure credentials:└── README.md                      # This file

```

```bash

az login---

az account show --query id -o tsv          # subscription id

az account show --query tenantId -o tsv    # tenant id## Terraform Infrastructure



az ad sp create-for-rbac \### Directory Layout

  --name "dissertation-terraform" \

  --role "Contributor" \Each cloud provider has its own isolated directory with independent provider configuration, state, and variables. This avoids cross-cloud authentication issues and allows independent deployments.

  --scopes "/subscriptions/<subscription-id>" \

  --sdk-auth```

```infra/terraform/

├── aws/           # AWS-specific configuration

Map the service principal output:├── azure/         # Azure-specific configuration

├── gcp/           # GCP-specific configuration

- `clientId` → `ARM_CLIENT_ID`└── modules/       # Cloud provider modules

- `clientSecret` → `ARM_CLIENT_SECRET`    ├── aws/

- `tenantId` → `ARM_TENANT_ID`    ├── azure/

- `subscriptionId` → `ARM_SUBSCRIPTION_ID`    └── gcp/

```

> **Troubleshooting 403 AuthorizationFailed:** Ensure the role assignment exists at the subscription level:

>### Cloud Provider Details

> ```bash

> az role assignment create \#### AWS Module

>   --assignee "<client-id>" \

>   --role "Contributor" \**Resources created:**

>   --scope "/subscriptions/<subscription-id>"- VPC with DNS support and hostnames enabled

> ```- Subnet in the first availability zone

- VPC Flow Logs for network traffic monitoring

#### GCP- CloudWatch Log Group for flow log storage

- IAM role and policy for VPC Flow Logs

```- All resources tagged according to governance requirements

GCP_PROJECT_ID

GCP_SA_KEY              (service account JSON key)```hcl

```module "aws" {

  source            = "../modules/aws"

### Dependabot  name_prefix       = "my-project-dev"

  cidr_block        = "10.42.0.0/16"

Dependabot is configured (`.github/dependabot.yml`) to check weekly for:  subnet_cidr_block = "10.42.1.0/24"

  tags = {

- GitHub Actions version updates    owner       = "platform-team"

- Terraform provider updates (for all 6 Terraform directories)    cost_center = "cc-001"

    compliance  = "baseline"

### Customisation  }

}

**Test only specific clouds:**```



```yaml| Input | Description | Type |

strategy:|-------|-------------|------|

  matrix:| `name_prefix` | Prefix for resource names | `string` |

    cloud: [aws]  # Only test AWS| `cidr_block` | VPC CIDR block | `string` |

```| `subnet_cidr_block` | Subnet CIDR block | `string` |

| `tags` | Tags to apply to all resources | `map(string)` |

**Add deployment step (use with caution):**

**Requirements:** Terraform >= 1.6.0, AWS provider ~> 6.31

```yaml

- name: Terraform Apply#### Azure Module

  if: github.ref == 'refs/heads/main'

  run: terraform -chdir=infra/terraform/${{ matrix.cloud }} apply -auto-approve**Resources created:**

```- Resource Group

- Virtual Network

---- Subnet

- All resources tagged according to governance requirements

## ArgoCD / GitOps Setup

```hcl

### Install ArgoCDmodule "azure" {

  source            = "../modules/azure"

```bash  name_prefix       = "my-project-dev"

kubectl create namespace argocd  location          = "eastus"

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml  cidr_block        = "10.42.0.0/16"

kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd  subnet_cidr_block = "10.42.1.0/24"

```  tags = {

    owner       = "platform-team"

### Access ArgoCD UI    cost_center = "cc-001"

    compliance  = "baseline"

```bash  }

# Get initial admin password}

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d```



# Port forward to access UI| Input | Description | Type |

kubectl port-forward svc/argocd-server -n argocd 8080:443|-------|-------------|------|

# Access at https://localhost:8080 (admin / <password from above>)| `name_prefix` | Prefix for resource names | `string` |

```| `location` | Azure region location | `string` |

| `cidr_block` | VNet CIDR block | `string` |

### Deploy the Application| `subnet_cidr_block` | Subnet CIDR block | `string` |

| `tags` | Tags to apply to all resources | `map(string)` |

1. Update `argocd/application.yaml` with your repository URL:

**Requirements:** Terraform >= 1.6.0, AzureRM provider ~> 4.58

   ```yaml

   source:#### GCP Module

     repoURL: https://github.com/YOUR_USERNAME/dissertation

   ```**Resources created:**

- VPC Network (custom mode, no auto-created subnets)

2. Apply:- Subnet with specified CIDR range



   ```bash> **Note:** GCP Compute networks and subnetworks do not support labels directly.

   kubectl apply -f argocd/application.yaml

   ``````hcl

module "gcp" {

3. Verify:  source            = "../modules/gcp"

  name_prefix       = "my-project-dev"

   ```bash  region            = "us-central1"

   kubectl get application -n argocd  cidr_block        = "10.42.0.0/16"

   kubectl get all -n dissertation  subnet_cidr_block = "10.42.1.0/24"

   ```}

```

The ArgoCD application is configured with:

| Input | Description | Type |

- **Automated sync** with self-healing and pruning|-------|-------------|------|

- **Auto namespace creation** (`CreateNamespace=true`)| `name_prefix` | Prefix for resource names | `string` |

- **Retry policy** with exponential backoff (5 attempts, max 3 minutes)| `region` | GCP region | `string` |

| `cidr_block` | VPC CIDR block (kept for interface consistency) | `string` |

---| `subnet_cidr_block` | Subnet CIDR block | `string` |



## Pre-commit Hooks**Requirements:** Terraform >= 1.6.0, Google provider ~> 7.18



### Setup### Backend Configuration



```bashEach cloud directory has a `backend.tf.example` file. To use a remote backend:

pip install pre-commit

pre-commit install1. Choose your target cloud directory (`aws/`, `azure/`, or `gcp/`)

pre-commit run --all-files   # Test on all files2. Copy `backend.tf.example` to `backend.tf`

```3. Edit with your backend-specific settings



### What Gets Checked| Cloud | Backend | Lock Mechanism |

|-------|---------|----------------|

- Trailing whitespace & end-of-file fixes| AWS | S3 bucket | DynamoDB table |

- YAML syntax validation| Azure | Azure Storage Account | Built-in |

- Large file detection| GCP | Cloud Storage bucket | Built-in |

- Merge conflict markers

- Private key detection---

- Terraform formatting & validation

- Terraform documentation generation## Kubernetes Deployment

- Rego policy verification via Conftest

The sample application includes production-ready configurations:

### Skip Hooks (When Necessary)

- ✅ Resource requests and limits

```bash- ✅ Liveness and readiness probes

git commit --no-verify -m "urgent fix"- ✅ Security contexts (non-root, read-only filesystem, drop all capabilities)

SKIP=terraform_fmt git commit -m "commit message"- ✅ Pod Disruption Budget for high availability

```- ✅ Horizontal Pod Autoscaler (CPU and memory based)

- ✅ Proper labeling for governance compliance

---- ✅ Volume mounts for nginx with read-only root filesystem



## Troubleshooting### Manifests



### Terraform Issues| File | Kind | Purpose |

|------|------|---------|

**Provider authentication fails:**| `namespace.yaml` | Namespace | Creates `dissertation` namespace |

| `deployment.yaml` | Deployment | nginx 1.27 with 2 replicas, full security context |

```bash| `service.yaml` | Service | TCP port 80 exposure |

aws sts get-caller-identity  # AWS| `hpa.yaml` | HorizontalPodAutoscaler | Auto-scale 2–10 pods (70% CPU, 80% memory) |

az account show              # Azure| `pdb.yaml` | PodDisruptionBudget | Minimum 1 pod always available |

gcloud auth list             # GCP

```### Scalability Features



**Backend initialization fails:**1. **Horizontal Scaling**: HPA automatically scales pods based on CPU/Memory

2. **High Availability**: PDB ensures minimum availability during disruptions

- Ensure you've copied `backend.tf.example` to `backend.tf` and configured it3. **Resource Management**: Defined requests/limits enable efficient scheduling

- Check that you have permissions to access the state storage

---

**Run validation locally:**

## Policy Enforcement (OPA/Rego)

```bash

make tf-init CLOUD=aws### Kubernetes Policies

make tf-validate CLOUD=aws

```**Location:** `policies/kubernetes/required-labels.rego`



### Policy Issues| Rule | Description |

|------|-------------|

**Validate Rego syntax:**| Required Labels | `app.kubernetes.io/name`, `app.kubernetes.io/part-of`, `owner`, `compliance` |

| Resource Limits | All containers must define `resources.requests` and `resources.limits` |

```bash| Security Context | Must be defined; `privileged` must not be true; `readOnlyRootFilesystem` should be true |

opa check policies/terraform/security.rego| Health Probes | All containers should define `livenessProbe` and `readinessProbe` |

opa check policies/kubernetes/required-labels.rego

```**Test locally:**

```bash

**Test with verbose output:**conftest test k8s/app -p policies/kubernetes

```

```bash

opa eval --format pretty \### Terraform Policies

  --data policies/terraform \

  --input policies/terraform/sample-tfplan.json \**Location:** `policies/terraform/security.rego`

  "data.terraform"

```| Rule | Description |

|------|-------------|

**Kubernetes policies fail:**| Required Tags | `owner`, `cost_center`, `compliance`, `project`, `environment`, `managed_by` |

| Storage Security | S3/Azure Storage/GCS must not allow public access; S3 must have encryption; Azure must enable HTTPS only |

- Ensure all required labels are present on every resource| Network Security | AWS VPCs should have Flow Logs enabled; GCP firewalls should not allow unrestricted 0.0.0.0/0 ingress |

- Check that resource limits are defined on all containers

- Verify security contexts are properly configured> **Note:** Certain resource types that don't support tags/labels are automatically exempted (e.g., `aws_iam_role_policy`, `azurerm_subnet`, `google_compute_network`).



### ArgoCD Issues**Test locally:**

```bash

```bash# Against sample plan

kubectl logs -n argocd deployment/argocd-application-controlleropa eval --fail-defined --format pretty \

kubectl describe application dissertation-sample-api -n argocd  --data policies/terraform \

```  --input policies/terraform/sample-tfplan.json \

  "data.terraform.deny"

---

# Against a real plan

## Security Featuresterraform -chdir=infra/terraform/aws plan -out=tfplan

terraform -chdir=infra/terraform/aws show -json tfplan > tfplan.json

1. **Policy Enforcement** — Automated validation before any deploymentopa eval --fail-defined --format pretty \

2. **Security Contexts** — Non-root containers, read-only filesystems, dropped capabilities  --data policies/terraform \

3. **Network Security** — HTTPS-only, no public access by default, VPC Flow Logs  --input tfplan.json \

4. **Secret Management** — All credentials stored in GitHub Secrets, never committed  "data.terraform.deny"

5. **Dependency Scanning** — Dependabot monitors for outdated dependencies```

6. **Pre-commit Hooks** — Private key detection, secret scanning before commits

### Adding New Policies

---

**Kubernetes:**

## Best Practices```rego

deny[msg] {

1. **Always create feature branches** — Don't push directly to main  # Your condition logic

2. **Wait for CI checks** before merging pull requests  msg := sprintf("Your error message: %v", [variables])

3. **Review policy violations** carefully — they're there for a reason}

4. **Keep dependencies updated** — Merge Dependabot PRs regularly```

5. **Monitor ArgoCD** — Ensure applications stay in sync

6. **Use pre-commit hooks** — Catch issues before they reach CI**Terraform:**

```rego

---deny contains msg if {

  some rc in input.resource_changes

## Notes  # Your condition logic

  msg := sprintf("Your error message: %v", [variables])

- This is intentionally provider-neutral at the orchestration level}

- Cloud-specific details are isolated inside provider modules```

- Governance controls are codified and enforced before deployment

- The project demonstrates scalability through automated multi-cloud testing---



---## CI/CD Pipeline



## License### Overview



This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.The GitHub Actions workflow (`.github/workflows/pipeline.yml`) runs on every push to `main` and on all pull requests. It uses a matrix strategy to test all three cloud providers in parallel.



## Acknowledgments**Pipeline stages:**

1. **Terraform Format Check** — Ensures code consistency

This implementation demonstrates concepts from the dissertation:2. **Terraform Init & Validate** — Verifies syntax (`-backend=false` for CI)

*"Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines"*3. **Terraform Plan** — Generates plans per cloud provider

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
