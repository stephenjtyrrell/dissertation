# CI/CD Setup Guide

This guide helps you set up the continuous integration and deployment pipeline for this project.

## GitHub Actions Setup

The project includes a GitHub Actions workflow that automatically validates and tests infrastructure code across all three cloud providers.

### Prerequisites

- GitHub repository
- Cloud provider credentials (for actual deployments)

### Step 1: Configure Repository Secrets

If you plan to actually deploy infrastructure (not just validate), configure these secrets in your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

#### For AWS Deployments

```
AWS_ACCESS_KEY_ID: your-aws-access-key
AWS_SECRET_ACCESS_KEY: your-aws-secret-key
AWS_DEFAULT_REGION: us-east-1
```

#### For Azure Deployments

```
ARM_CLIENT_ID: your-client-id
ARM_CLIENT_SECRET: your-client-secret
ARM_SUBSCRIPTION_ID: your-subscription-id
ARM_TENANT_ID: your-tenant-id
```

To generate these values, create a service principal in Azure and capture the output:

```bash
az login
az account show --query id -o tsv # subscription id
az account show --query tenantId -o tsv # tenant id

az ad sp create-for-rbac \
  --name "dissertation-terraform" \
  --role "Contributor" \
  --scopes "/subscriptions/<subscription-id>" \
  --sdk-auth
```

Map the service principal output to secrets:

- `clientId` → `ARM_CLIENT_ID`
- `clientSecret` → `ARM_CLIENT_SECRET`
- `tenantId` → `ARM_TENANT_ID`
- `subscriptionId` → `ARM_SUBSCRIPTION_ID` (from `az account show` above)

#### For GCP Deployments

```
GCP_PROJECT_ID: your-project-id
GCP_SA_KEY: your-service-account-json-key
```

### Step 2: Enable GitHub Actions

1. Go to your repository on GitHub
2. Click on "Actions" tab
3. Enable workflows if prompted

### Step 3: Customize the Workflow (Optional)

Edit `.github/workflows/pipeline.yml` to customize:

- Terraform version
- OPA version
- Conftest version
- Which clouds to test (in matrix strategy)
- When to run (triggers)

### Step 4: Test the Pipeline

1. Make a change to any file
2. Commit and push to a feature branch
3. Create a pull request
4. Watch the pipeline run

```bash
git checkout -b test/pipeline
echo "# Test" >> README.md
git add README.md
git commit -m "test: trigger pipeline"
git push origin test/pipeline
```

## ArgoCD Setup

For GitOps-based Kubernetes deployments:

### Step 1: Install ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
```

### Step 2: Access ArgoCD UI

```bash
# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at https://localhost:8080
# Username: admin
# Password: (from above command)
```

### Step 3: Deploy the Application

Update `argocd/application.yaml` with your repository URL:

```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/dissertation
```

Then apply:

```bash
kubectl apply -f argocd/application.yaml
```

### Step 4: Verify Deployment

```bash
# Check ArgoCD application status
kubectl get application -n argocd

# Check deployed resources
kubectl get all -n dissertation

# Watch ArgoCD sync the application
argocd app get dissertation-sample-api
```

## Dependabot Setup

Dependabot automatically creates PRs to update dependencies.

### Configuration

The configuration is already in `.github/dependabot.yml`:

- Checks for GitHub Actions updates weekly
- Checks for Terraform provider updates weekly

### Customize Schedule

Edit `.github/dependabot.yml` to change frequency:

```yaml
schedule:
  interval: "daily"  # or "weekly", "monthly"
```

## Pre-commit Hooks Setup

Pre-commit hooks run checks before each commit to catch issues early.

### Install Pre-commit

```bash
# Using pip
pip install pre-commit

# Using brew (macOS)
brew install pre-commit
```

### Install Hooks

```bash
# From repository root
pre-commit install

# Test hooks on all files
pre-commit run --all-files
```

### What Gets Checked

- Trailing whitespace
- YAML syntax
- Large files
- Merge conflicts
- Private keys
- Terraform formatting
- Terraform validation
- Rego policy verification

### Skip Hooks (When Necessary)

```bash
# Skip all hooks
git commit --no-verify -m "urgent fix"

# Skip specific hook
SKIP=terraform_fmt git commit -m "commit message"
```

## Status Badges

Add these badges to your README.md:

```markdown
![CI](https://github.com/YOUR_USERNAME/dissertation/workflows/vendor-agnostic-multicloud-pipeline/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

## Monitoring Pipeline Results

### View Workflow Runs

- Go to "Actions" tab in GitHub
- Click on a workflow run to see details
- Download artifacts (Terraform plans) for review

### Check Policy Violations

If policy checks fail:

1. Review the policy evaluation step output
2. Identify which policy rule failed
3. Fix the violation in your code
4. Push the fix and watch the pipeline run again

### Troubleshooting

**Pipeline fails on Terraform validation:**
```bash
# Run locally to debug
make tf-init
make tf-validate
```

**Pipeline fails on policy checks:**
```bash
# Test policies locally
make policy-tf
make policy-k8s
```

**ArgoCD sync fails:**
```bash
# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-application-controller

# Check application events
kubectl describe application dissertation-sample-api -n argocd
```

## Best Practices

1. **Always create feature branches** - Don't push directly to main
2. **Wait for CI checks** before merging pull requests
3. **Review policy violations** carefully - they're there for a reason
4. **Keep dependencies updated** - Merge Dependabot PRs regularly
5. **Monitor ArgoCD** - Ensure applications stay in sync
6. **Use pre-commit hooks** - Catch issues before they reach CI

## Advanced Configuration

### Matrix Testing

The pipeline tests all three cloud providers in parallel. To test only specific clouds:

```yaml
# .github/workflows/pipeline.yml
strategy:
  matrix:
    cloud: [aws]  # Only test AWS
```

### Add Deployment Step

To automatically apply Terraform after validation (use with caution):

```yaml
- name: Terraform Apply
  if: github.ref == 'refs/heads/main'
  run: terraform -chdir=infra/terraform apply -auto-approve -var="cloud=${{ matrix.cloud }}"
```

### Slack Notifications

Add Slack notifications for pipeline status:

```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

## Security Considerations

1. **Never commit secrets** - Use GitHub Secrets
2. **Rotate credentials regularly** - Update secrets periodically
3. **Use OIDC when possible** - For GitHub Actions authentication
4. **Review Dependabot PRs** - Don't auto-merge without review
5. **Limit repository access** - Use CODEOWNERS and branch protection

## Next Steps

- [ ] Configure cloud provider credentials
- [ ] Set up branch protection rules
- [ ] Enable required status checks
- [ ] Configure CODEOWNERS
- [ ] Set up notification channels
- [ ] Create deployment runbooks
