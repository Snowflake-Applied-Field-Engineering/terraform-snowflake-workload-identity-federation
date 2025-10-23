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
  source = "../../" # TODO Because examples will often be copied into other repositories for customization, any module blocks should have their source set to the address an external caller would use, not to a relative path.  https://developer.hashicorp.com/terraform/language/modules/develop/structure

  #   source = "./modules/wif-aws-iam"
  #   source = "git::https://github.com/Snowflake-Applied-Field-Engineering/terraform-snowflake-workload-identity-federation.git?ref=init"

  # source = "/Users/mbarreiro/src/terraform-snowflake-workload-identity-federation"

  #   name_prefix = var.name_prefix
  # tags = var.tags
  wif_test_database     = var.wif_test_database
  wif_role_name         = var.wif_role_name
  wif_user_name         = var.wif_user_name
  wif_default_warehouse = var.wif_default_warehouse
  wif_test_schema       = var.wif_test_schema
  aws_role_arn          = var.aws_role_arn
  # azure_tenant_id = var.azure_tenant_id
  # azure_sp_id = var.azure_sp_id
  # gcp_project_id = var.gcp_project_id
  # gcp_service_account_email = var.gcp_service_account_email
}
