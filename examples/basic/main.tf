# examples/basic/main.tf
# Basic usage example

# Configure providers (if needed)
# provider "aws" {
#   region = var.region
# }

# provider "snowflake" {
#   account = var.snowflake_account
#   region  = var.snowflake_region
#   role    = var.snowflake_role
#   user    = var.snowflake_user
# }

# Use the module
# module "example" {
#   source = "../../"
#
#   name        = var.name
#   environment = var.environment
#   tags        = var.tags
# }

# Example: Snowflake Database Module
# module "snowflake_database" {
#   source = "../../"
#
#   database_name       = "DEMO_DB"
#   data_retention_days = 7
#
#   tags = {
#     Environment = "dev"
#     Project     = "demo"
#     ManagedBy   = "terraform"
#   }
# }

# Add your basic example here
