# Architecture Documentation

## System Architecture

This project implements a vendor-agnostic multi-cloud deployment pipeline with the following architecture:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          Developer Workflow                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐         │
│  │   Code   │───▶│   Git    │───▶│  GitHub  │───▶│   CI/CD  │         │
│  │  Changes │    │  Commit  │    │   Push   │    │ Pipeline │         │
│  └──────────┘    └──────────┘    └──────────┘    └─────┬────┘         │
└──────────────────────────────────────────────────────────┼──────────────┘
                                                            │
                    ┌───────────────────────────────────────┼───────────────┐
                    │          CI/CD Pipeline (GitHub Actions)              │
                    │                                                        │
                    │  ┌──────────────────────────────────────────────┐    │
                    │  │  1. Terraform Format & Validation            │    │
                    │  └──────────────┬───────────────────────────────┘    │
                    │                 │                                     │
                    │  ┌──────────────▼───────────────────────────────┐    │
                    │  │  2. Multi-Cloud Plan Generation              │    │
                    │  │     (AWS, Azure, GCP in parallel)            │    │
                    │  └──────────────┬───────────────────────────────┘    │
                    │                 │                                     │
                    │  ┌──────────────▼───────────────────────────────┐    │
                    │  │  3. Policy Evaluation (OPA)                  │    │
                    │  │     - Terraform Security Policies            │    │
                    │  │     - Kubernetes Governance Policies         │    │
                    │  └──────────────┬───────────────────────────────┘    │
                    │                 │                                     │
                    │                 │ [Policies Pass]                     │
                    └─────────────────┼─────────────────────────────────────┘
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
│  │  (Conditional   │  │                           │  │  - Deployment   │  │
│  │   count logic)  │  │                           │  │  - Service      │  │
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

## Component Details

### 1. Infrastructure Layer (Terraform)

**Purpose**: Provision cloud infrastructure in a vendor-agnostic manner

**Components**:
- **Root Module** (`infra/terraform/main.tf`): 
  - Selects target cloud provider via variable
  - Routes to appropriate provider module using conditional count
  - Applies consistent naming and tagging

- **Provider Modules** (`infra/terraform/modules/{aws,azure,gcp}/`):
  - Encapsulate cloud-specific resource creation
  - Provide consistent interface across providers
  - Handle provider-specific configurations

**Benefits**:
- Single codebase for multiple clouds
- Easy to switch between providers
- Consistent resource naming and tagging

### 2. Policy Layer (OPA/Rego)

**Purpose**: Enforce governance and security requirements before deployment

**Components**:
- **Terraform Policies** (`policies/terraform/security.rego`):
  - Required tags/labels validation
  - Security configurations (encryption, HTTPS, etc.)
  - Network access controls
  - Evaluated before infrastructure deployment

- **Kubernetes Policies** (`policies/kubernetes/required-labels.rego`):
  - Required labels enforcement
  - Resource limits validation
  - Security context requirements
  - Health probe validation
  - Evaluated before application deployment

**Benefits**:
- Shift-left security
- Automated compliance checking
- Consistent governance across environments
- Policy-as-Code version control

### 3. CI/CD Pipeline (GitHub Actions)

**Purpose**: Automate validation, testing, and deployment across all cloud providers

**Workflow**:
1. **Format Check**: Ensures code consistency
2. **Validation**: Verifies Terraform syntax
3. **Multi-Cloud Planning**: Generates plans for all three providers (matrix strategy)
4. **Policy Evaluation**: Runs OPA policies against generated plans
5. **Artifact Storage**: Saves plans for review

**Benefits**:
- Automated testing across all providers
- Early detection of configuration issues
- Consistent deployment process
- Audit trail via artifacts

### 4. Application Layer (Kubernetes)

**Purpose**: Deploy applications using GitOps methodology

**Components**:
- **Kubernetes Manifests** (`k8s/app/`):
  - Namespace definition
  - Deployment with security best practices
  - Service for networking
  - HPA for auto-scaling
  - PDB for high availability

- **ArgoCD Application** (`argocd/application.yaml`):
  - Monitors Git repository
  - Automatically syncs changes
  - Self-healing and pruning enabled

**Benefits**:
- Declarative deployments
- Git as single source of truth
- Automatic synchronization
- Rollback capabilities

## Data Flow

```
Developer → Git → GitHub → CI/CD Pipeline
                              ↓
                    ┌─────────┴──────────┐
                    │                    │
                    ▼                    ▼
              Policy Check         Format/Validate
                    │                    │
                    └─────────┬──────────┘
                              ↓
                        [Pass/Fail]
                              │
                    ┌─────────┴──────────┐
                    │                    │
                    ▼                    ▼
            Infrastructure         Application
            (Terraform)           (ArgoCD → K8s)
```

## Scalability Features

1. **Horizontal Scaling**: HPA automatically scales pods based on CPU/Memory
2. **Multi-Cloud Support**: Same codebase deploys to any cloud provider
3. **Modular Architecture**: Easy to add new modules or providers
4. **Parallel Execution**: CI/CD matrix strategy tests all providers simultaneously

## Security Features

1. **Policy Enforcement**: Automated validation before deployment
2. **Security Contexts**: Non-root containers, read-only filesystems
3. **Network Security**: HTTPS-only, no public access by default
4. **Encryption**: Required for storage resources
5. **Least Privilege**: Minimal IAM permissions (to be implemented)

## High Availability

1. **Pod Disruption Budget**: Ensures minimum replicas during updates
2. **Multi-AZ Deployment**: Subnets across availability zones
3. **Health Probes**: Automatic detection and recovery of failed pods
4. **Auto-Scaling**: Dynamic adjustment to load

## Governance

1. **Required Tagging**: All resources tagged with owner, cost center, compliance
2. **Policy-as-Code**: Version-controlled governance rules
3. **Audit Trail**: Git history and CI/CD logs
4. **Code Owners**: Automated review assignments

## Future Enhancements

- [ ] Add monitoring and observability stack
- [ ] Implement multi-region deployments
- [ ] Add disaster recovery procedures
- [ ] Integrate secrets management
- [ ] Add cost optimization policies
- [ ] Implement blue-green deployments
