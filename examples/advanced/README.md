# Advanced Example

This example demonstrates advanced usage patterns including:
- Multiple module instances
- Complex networking configurations
- Cross-module dependencies
- Advanced Snowflake features

## Usage

1. **Configure variables**

   Create a `terraform.tfvars` file:

   ```hcl
   name        = "my-advanced-setup"
   environment = "prod"
   region      = "us-east-1"

   vpc_id     = "vpc-12345678"
   subnet_ids = ["subnet-12345678", "subnet-87654321"]

   enable_replication = true

   tags = {
     Project     = "production-app"
     Owner       = "platform-team@example.com"
     CostCenter  = "engineering"
     Compliance  = "SOC2"
   }
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Review the plan**

   ```bash
   terraform plan
   ```

4. **Apply the configuration**

   ```bash
   terraform apply
   ```

5. **Clean up**

   ```bash
   terraform destroy
   ```

## What This Example Creates

This example creates:
- Primary resource with full configuration
- Secondary resource with dependencies
- Network integration
- Monitoring and logging setup
- [Add more details]

## Architecture

```
┌─────────────────────────────────────────┐
│           VPC (Existing)                │
│                                         │
│  ┌──────────────┐    ┌──────────────┐  │
│  │   Primary    │───▶│  Secondary   │  │
│  │   Module     │    │   Module     │  │
│  └──────────────┘    └──────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | ~> 5.0 |
| snowflake | ~> 0.94 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name for resources | `string` | `"advanced-example"` | no |
| environment | Environment name | `string` | `"prod"` | no |
| vpc_id | VPC ID for network resources | `string` | n/a | yes |
| subnet_ids | List of subnet IDs | `list(string)` | n/a | yes |
| enable_replication | Enable database replication | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| primary_id | The ID of the primary resource |
| secondary_id | The ID of the secondary resource |
| connection_info | Connection information for all resources |

## Notes

- This example requires existing VPC and subnet resources
- Ensure proper IAM permissions are configured
- Review security group rules before applying
- Consider cost implications of running multiple resources
