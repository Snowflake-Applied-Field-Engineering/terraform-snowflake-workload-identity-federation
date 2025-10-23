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
################################################################################
# Module
################################################################################
module "wif_aws" {

  # Add your basic example here
  source = "../../"

  csp          = "aws"
  aws_role_arn = var.aws_role_arn

  wif_default_warehouse = var.wif_default_warehouse
  wif_role_name         = var.wif_role_name
  wif_test_database     = var.wif_test_database
  wif_test_schema       = var.wif_test_schema
  wif_user_name         = var.wif_user_name
}
