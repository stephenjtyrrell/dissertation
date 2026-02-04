# Policy Documentation

This directory contains OPA (Open Policy Agent) policies for governance enforcement.

## Kubernetes Policies

Location: `kubernetes/required-labels.rego`

### Rules Enforced

1. **Required Labels**: All Kubernetes resources must have these labels:
   - `app.kubernetes.io/name`
   - `app.kubernetes.io/part-of`
   - `owner`
   - `compliance`

2. **Resource Limits**: All containers in Deployments must define:
   - `resources.requests` (CPU and memory)
   - `resources.limits` (CPU and memory)

3. **Security Context**: All containers must have:
   - `securityContext` defined
   - `privileged` must not be true
   - `readOnlyRootFilesystem` should be true

4. **Health Probes**: All containers should define:
   - `livenessProbe`
   - `readinessProbe`

### Testing Kubernetes Policies

```bash
# Test against manifests
conftest test k8s/app -p policies/kubernetes

# Test specific file
conftest test k8s/app/deployment.yaml -p policies/kubernetes
```

## Terraform Policies

Location: `terraform/security.rego`

### Rules Enforced

1. **Required Tags/Labels**: All managed resources must have:
   - `owner`
   - `cost_center`
   - `compliance`
   - `project`
   - `environment`
   - `managed_by`

2. **Storage Security**:
   - S3 buckets, Azure Storage, and GCS must not allow public access
   - AWS S3 buckets must have server-side encryption enabled
   - Azure Storage accounts must enable HTTPS traffic only

3. **Network Security**:
   - AWS VPCs should have VPC Flow Logs enabled
   - GCP firewall rules should not allow unrestricted ingress from 0.0.0.0/0

### Testing Terraform Policies

```bash
# Test against sample plan
opa eval --fail-defined --format pretty \
  --data policies/terraform \
  --input policies/terraform/sample-tfplan.json \
  "data.terraform.deny"

# Test against real plan
terraform -chdir=infra/terraform plan -var="cloud=aws" -out=tfplan
terraform -chdir=infra/terraform show -json tfplan > tfplan.json
opa eval --fail-defined --format pretty \
  --data policies/terraform \
  --input tfplan.json \
  "data.terraform.deny"
```

## Policy Development

### Adding New Kubernetes Policies

1. Edit `kubernetes/required-labels.rego`
2. Add new `deny` rule:
   ```rego
   deny contains msg if {
     # Your condition logic
     msg := sprintf("Your error message: %v", [variables])
   }
   ```
3. Test against manifests
4. Update this README

### Adding New Terraform Policies

1. Edit `terraform/security.rego`
2. Add new `deny` rule:
   ```rego
   deny contains msg if {
     some rc in input.resource_changes
     # Your condition logic
     msg := sprintf("Your error message: %v", [variables])
   }
   ```
3. Update sample plan if needed
4. Test the policy
5. Update this README

## Policy Exemptions

To exempt specific resources from policy checks (use sparingly):

**For Kubernetes**: Add annotation
```yaml
metadata:
  annotations:
    policy.exemption: "justification here"
```

**For Terraform**: Use conditional logic in policies or tag resources appropriately

## References

- [OPA Documentation](https://www.openpolicyagent.org/docs/latest/)
- [Rego Language Reference](https://www.openpolicyagent.org/docs/latest/policy-language/)
- [Conftest Documentation](https://www.conftest.dev/)
- [Terraform JSON Output](https://www.terraform.io/docs/internals/json-format.html)
