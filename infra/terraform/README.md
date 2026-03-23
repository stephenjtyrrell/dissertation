# Terraform Infrastructure

This directory contains cloud-specific Terraform configurations for AWS, Azure, and GCP.

## Structure

```
terraform/
├── aws/           # AWS-specific configuration
├── azure/         # Azure-specific configuration
├── gcp/           # GCP-specific configuration
└── modules/       # Shared cloud provider modules
    ├── aws/
    ├── azure/
    └── gcp/
```

## Usage

Each cloud provider has its own directory with isolated provider configuration:

### AWS
```bash
cd aws
terraform init
terraform plan
terraform apply
```

### Azure
```bash
cd azure
terraform init
terraform plan
terraform apply
```

### GCP
```bash
cd gcp
terraform init
terraform plan
terraform apply
```

## Benefits of Separated Directories

1. **No cross-cloud authentication issues** - Each directory only initializes the provider it needs
2. **Isolated state** - Each cloud has its own state file
3. **Cleaner configuration** - No conditionals or dummy credentials needed
4. **Independent deployments** - Deploy to one cloud without affecting others
5. **Easier to maintain** - Cloud-specific settings stay in their own directory

## Backend Configuration

Each cloud directory has a `backend.tf.example` file. Copy it to `backend.tf` and configure for your state backend:

- **AWS**: S3 + DynamoDB
- **Azure**: Azure Storage Account
- **GCP**: Cloud Storage bucket
