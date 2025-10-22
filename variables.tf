# variables.tf
# Input variable declarations

# Required Variables
# variable "name" {
#   description = "Name of the resource"
#   type        = string
#   validation {
#     condition     = length(var.name) > 0 && length(var.name) <= 255
#     error_message = "Name must be between 1 and 255 characters."
#   }
# }

# Optional Variables
# variable "tags" {
#   description = "A map of tags to apply to resources"
#   type        = map(string)
#   default     = {}
# }

# variable "environment" {
#   description = "Environment name (e.g., dev, staging, prod)"
#   type        = string
#   default     = "dev"
#   validation {
#     condition     = contains(["dev", "staging", "prod"], var.environment)
#     error_message = "Environment must be dev, staging, or prod."
#   }
# }

# Snowflake-specific Variables
# variable "snowflake_account" {
#   description = "Snowflake account identifier"
#   type        = string
# }

# variable "snowflake_region" {
#   description = "Snowflake region"
#   type        = string
# }

# variable "database_name" {
#   description = "Name of the Snowflake database"
#   type        = string
# }

# variable "data_retention_days" {
#   description = "Number of days to retain data"
#   type        = number
#   default     = 1
#   validation {
#     condition     = var.data_retention_days >= 0 && var.data_retention_days <= 90
#     error_message = "Data retention days must be between 0 and 90."
#   }
# }

# AWS-specific Variables
# variable "region" {
#   description = "AWS region"
#   type        = string
#   default     = "us-east-1"
# }

# Complex Type Examples
# variable "network_config" {
#   description = "Network configuration"
#   type = object({
#     vpc_id            = string
#     subnet_ids        = list(string)
#     security_group_ids = list(string)
#   })
#   default = null
# }

# Add your variable definitions here
