# Basic Example

This example demonstrates the basic usage of the Terraform module.

## Usage

1. **Configure variables**

   Create a `terraform.tfvars` file:

   ```hcl
   name        = "my-resource"
   environment = "dev"
   region      = "us-east-1"

   tags = {
     Project   = "demo"
     Owner     = "team@example.com"
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
- [List the resources created]

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | ~> 5.0 |
| snowflake | ~> 0.94 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the resource | `string` | `"basic-example"` | no |
| environment | Environment name | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the created resource |
| name | The name of the created resource |
