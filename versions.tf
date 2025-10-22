# versions.tf
# Terraform and provider version constraints

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # AWS Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    # Snowflake Provider
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.94"
    }

    # Add other providers as needed
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.5"
    # }
  }
}

# Provider configurations can be added here or in a separate providers.tf file
# Note: For reusable modules, provider configurations should typically be
# defined by the calling module, not within the module itself.

# Example provider configurations (uncomment if needed):
# provider "aws" {
#   region = var.region
# }

# provider "snowflake" {
#   account  = var.snowflake_account
#   region   = var.snowflake_region
#   role     = var.snowflake_role
#   user     = var.snowflake_user
# }
