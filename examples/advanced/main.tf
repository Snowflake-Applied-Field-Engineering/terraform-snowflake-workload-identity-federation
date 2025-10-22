# examples/advanced/main.tf
# Advanced usage example with multiple features

# Configure providers
# provider "aws" {
#   region = var.region
# }

# provider "snowflake" {
#   account = var.snowflake_account
#   region  = var.snowflake_region
#   role    = var.snowflake_role
#   user    = var.snowflake_user
# }

# Advanced example with multiple modules and configurations
# module "primary" {
#   source = "../../"
#
#   name        = "${var.name}-primary"
#   environment = var.environment
#
#   # Advanced configuration options
#   network_config = {
#     vpc_id             = var.vpc_id
#     subnet_ids         = var.subnet_ids
#     security_group_ids = var.security_group_ids
#   }
#
#   tags = merge(
#     var.tags,
#     {
#       Component = "primary"
#     }
#   )
# }

# module "secondary" {
#   source = "../../"
#
#   name        = "${var.name}-secondary"
#   environment = var.environment
#
#   # Reference outputs from primary module
#   # depends_on = [module.primary]
#
#   tags = merge(
#     var.tags,
#     {
#       Component = "secondary"
#     }
#   )
# }

# Example: Complete Snowflake Setup
# module "snowflake_environment" {
#   source = "../../"
#
#   database_name       = "PROD_DB"
#   data_retention_days = 30
#
#   # Advanced features
#   enable_replication = true
#   failover_groups    = ["PRIMARY", "SECONDARY"]
#
#   tags = {
#     Environment = "production"
#     Compliance  = "SOC2"
#     ManagedBy   = "terraform"
#   }
# }

# Add your advanced example here
