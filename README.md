# Dissertation Implementation: Vendor-Agnostic Multi-Cloud Pipeline

This repository provides a practical implementation for the dissertation topic:

`Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines`

## What is included

- **`infra/terraform/`**: Multi-cloud Infrastructure as Code (AWS, Azure, GCP) with a consistent interface
- **`policies/`**: OPA/Rego governance policies for Terraform and Kubernetes
- **`.github/workflows/pipeline.yml`**: CI pipeline for IaC validation and policy checks across all cloud providers
- **`k8s/app/`**: Production-ready Kubernetes workload with security best practices, deployed through GitOps
- **`argocd/application.yaml`**: Argo CD app manifest for GitOps delivery

## Architecture

This project demonstrates vendor-agnostic multi-cloud deployment through:
- **Abstraction Layer**: Consistent Terraform interface regardless of cloud provider
- **Policy-as-Code**: Automated governance enforcement with OPA
- **GitOps**: Declarative Kubernetes deployments via ArgoCD
- **CI/CD**: Automated validation and testing for all three cloud providers

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.6.0
- [OPA](https://www.openpolicyagent.org/docs/latest/#1-download-opa) >= 0.50.0
- [Conftest](https://www.conftest.dev/install/) >= 0.40.0
- Cloud provider credentials (AWS, Azure, or GCP)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (for Kubernetes deployment)
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) (for GitOps)

## Quick start

### 1. Configure Cloud Provider

Select target cloud (`aws`, `azure`, or `gcp`) and set up credentials:

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
# Copy and customize terraform variables
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars

# Initialize and validate
cd infra/terraform
terraform init
terraform validate
terraform plan -var="cloud=aws" -out=tfplan
terraform show -json tfplan > tfplan.json
```

### 3. Evaluate Governance Policies

**Terraform policies:**
```bash
opa eval --fail-defined --format pretty \
  --data ../../policies/terraform \
  --input tfplan.json \
  "data.terraform.deny"
```

**Kubernetes policies:**
```bash
conftest test ../../k8s/app -p ../../policies/kubernetes
```

### 4. Apply Infrastructure (if policies pass)

```bash
terraform apply -var="cloud=aws"
```

## Using the Makefile

The project includes a comprehensive Makefile for common tasks:

```bash
# Show all available commands
make help

# Run all checks
make all

# Terraform operations
make tf-init              # Initialize Terraform
make tf-fmt               # Format Terraform code
make tf-validate          # Validate configuration
make tf-plan CLOUD=aws    # Generate plan for specific cloud
make tf-apply CLOUD=azure # Apply changes
make tf-destroy CLOUD=gcp # Destroy resources

# Policy evaluation
make policy-tf            # Evaluate Terraform policies
make policy-k8s           # Evaluate Kubernetes policies

# Cleanup
make clean                # Remove generated files
```

## Project Structure

```
.
├── .github/
│   ├── workflows/
│   │   └── pipeline.yml          # CI/CD pipeline with matrix strategy
│   └── dependabot.yml             # Automated dependency updates
├── argocd/
│   └── application.yaml           # ArgoCD application manifest
├── infra/
│   └── terraform/
│       ├── main.tf                # Root module with cloud selection logic
│       ├── variables.tf           # Input variables
│       ├── outputs.tf             # Output values
│       ├── providers.tf           # Provider configurations
│       ├── versions.tf            # Version constraints
│       ├── terraform.tfvars.example  # Example variables file
│       ├── backend.tf.example     # Backend configuration examples
│       └── modules/
│           ├── aws/               # AWS-specific resources
│           ├── azure/             # Azure-specific resources
│           └── gcp/               # GCP-specific resources
├── k8s/
│   └── app/
│       ├── namespace.yaml         # Namespace definition
│       ├── deployment.yaml        # Application deployment (production-ready)
│       ├── service.yaml           # Service definition
│       ├── pdb.yaml              # Pod Disruption Budget
│       └── hpa.yaml              # Horizontal Pod Autoscaler
├── policies/
│   ├── kubernetes/
│   │   └── required-labels.rego   # K8s governance policies
│   └── terraform/
│       ├── security.rego          # Terraform security policies
│       └── sample-tfplan.json     # Sample plan for testing
├── CONTRIBUTING.md                # Contribution guidelines
├── LICENSE                        # MIT License
├── Makefile                       # Build automation
└── README.md                      # This file
```

## Cloud Provider Details

### AWS
- Creates VPC with DNS support and hostnames enabled
- Deploys subnet in first availability zone
- Applies consistent tagging

### Azure
- Creates Resource Group
- Deploys Virtual Network and Subnet
- Applies consistent tagging

### GCP
- Creates VPC network (custom mode)
- Deploys subnet with specified CIDR
- Note: GCP networks don't support labels directly

## Kubernetes Deployment Features

The sample application includes production-ready configurations:
- ✅ Resource requests and limits
- ✅ Liveness and readiness probes
- ✅ Security contexts (non-root, read-only filesystem)
- ✅ Pod Disruption Budget for high availability
- ✅ Horizontal Pod Autoscaler
- ✅ Proper labeling for governance

## Policy Enforcement

### Kubernetes Policies
- Required labels validation
- Resource limits enforcement
- Security context requirements
- Health probe requirements
- Read-only filesystem enforcement

### Terraform Policies
- Required tags/labels on all resources
- Public access restrictions
- Encryption requirements
- Network security validations

## CI/CD Pipeline

The GitHub Actions workflow includes:
- Multi-cloud matrix strategy (tests all three providers)
- Terraform formatting, initialization, and validation
- Policy evaluation for both Terraform and Kubernetes
- Artifact upload for Terraform plans
- Automated dependency updates via Dependabot

## Troubleshooting

### Terraform Issues

**Problem: Provider authentication fails**
```bash
# Verify credentials are set correctly
aws sts get-caller-identity  # AWS
az account show              # Azure
gcloud auth list             # GCP
```

**Problem: Backend initialization fails**
- Ensure you've configured the backend in `backend.tf`
- Check that you have permissions to access the state storage

### Policy Issues

**Problem: Policy evaluation fails**
```bash
# Validate Rego syntax
opa check policies/terraform/security.rego
opa check policies/kubernetes/required-labels.rego

# Test policies with verbose output
opa eval --format pretty \
  --data policies/terraform \
  --input policies/terraform/sample-tfplan.json \
  "data.terraform"
```

**Problem: Kubernetes policies fail**
- Ensure all required labels are present
- Check that resource limits are defined
- Verify security contexts are properly configured

## Development

### Pre-commit Hooks

Install pre-commit hooks for automatic validation:

```bash
pip install pre-commit
pre-commit install
```

This will automatically run:
- Terraform formatting and validation
- YAML linting
- Secret detection
- Trailing whitespace cleanup

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

## Notes

- This is intentionally provider-neutral at the orchestration level
- Cloud-specific details are isolated inside provider modules
- Governance controls are codified and enforced before deployment
- The project demonstrates scalability through automated multi-cloud testing

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This implementation demonstrates concepts from the dissertation:
*"Impact of governance and scalability with automated vendor-agnostic multi-cloud deployment pipelines"*
