################################################################################
# General
################################################################################

variable "csp" {
  description = "Type of WIF identity to create"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.csp)
    error_message = "Invalid WIF identity type: ${var.csp}. Valid types are: aws, azure, gcp."
  }
}

################################################################################
# Snowflake WIF variables
################################################################################

variable "wif_role_name" {
  description = "Name of the WIF test role"
  type        = string
  default     = "WIF_TEST_ROLE"
}

variable "wif_user_name" {
  description = "Name of the WIF test user"
  type        = string
  default     = "WIF_TEST_USER"
}

variable "wif_default_warehouse" {
  description = "Default warehouse for the WIF test user/role (must exist)"
  type        = string
  default     = null
}

variable "wif_test_database" {
  description = "Database to test privileges of the WIF test user/role(must exist)"
  type        = string

}

variable "wif_test_schema" {
  description = "Schema to test privileges of the WIF test user/role(must exist)"
  type        = string
  default     = null
}

################################################################################
# AWS WIF variables
################################################################################

variable "aws_role_arn" {
  description = "ARN of the AWS role to use for WIF"
  type        = string
  default     = null
}

################################################################################
# Azure WIF variables
################################################################################

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  default     = null
}

variable "azure_sp_id" {
  description = "Effective Azure SP ID"
  type        = string
  default     = null
}


################################################################################
# GCP WIF variables
################################################################################

# variable "gcp_wif_project_id" {
#   description = "GCP project ID"
#   type        = string
# }

# variable "gcp_wif_service_account_email_effective" {
#   description = "Effective GCP WIF service account email"
#   type        = string
# }
