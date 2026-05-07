# Example: AWS with Existing IAM Role

This example shows how to configure an existing AWS role for WIF in Snowflake.
<!-- # Basic Example

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 2.9, <= 2.12 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_wif_aws"></a> [wif\_aws](#module\_wif\_aws) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
