# Contributing to Dissertation Project

Thank you for your interest in contributing to this dissertation implementation project!

## Getting Started

1. **Fork the repository** and clone it locally
2. **Set up your development environment**:
   ```bash
   # Install required tools
   brew install terraform
   brew install opa
   brew install conftest
   ```

3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Terraform Changes

1. Make your changes in the appropriate module or configuration file
2. Format your code:
   ```bash
   make tf-fmt
   ```
3. Validate your changes:
   ```bash
   make tf-validate
   ```
4. Test with all cloud providers:
   ```bash
   make tf-plan CLOUD=aws
   make tf-plan CLOUD=azure
   make tf-plan CLOUD=gcp
   ```

### Kubernetes Manifest Changes

1. Update the manifests in `k8s/app/`
2. Validate against policies:
   ```bash
   make policy-k8s
   ```

### Policy Changes

1. Update OPA/Rego policies in `policies/`
2. Test policies against sample data
3. Update tests if adding new rules

## Pull Request Process

1. **Ensure all tests pass**:
   ```bash
   make all
   ```

2. **Update documentation** if you're changing functionality

3. **Write clear commit messages** following conventional commits format:
   ```
   feat: add new feature
   fix: resolve bug
   docs: update documentation
   test: add tests
   refactor: refactor code
   ```

4. **Submit your PR** with:
   - Clear description of changes
   - Link to related issues
   - Screenshots if applicable
   - Test results

## Code Style

- **Terraform**: Follow [HashiCorp style guide](https://www.terraform.io/docs/language/syntax/style.html)
- **YAML**: 2 spaces for indentation
- **Rego**: 2 spaces for indentation
- Use `.editorconfig` for consistent formatting

## Policy Testing

All policies should be tested before submission:

```bash
# Test Kubernetes policies
conftest test k8s/app -p policies/kubernetes

# Test Terraform policies
opa eval --fail-defined --format pretty \
  --data policies/terraform \
  --input policies/terraform/sample-tfplan.json \
  "data.terraform.deny"
```

## Questions?

Feel free to open an issue for any questions or concerns.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
