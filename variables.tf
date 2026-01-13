################################################################################
# General
################################################################################

variable "wif_type" {
  description = "The type of WIF identity to create. Must be one of: aws, azure, gcp, oidc."
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure", "gcp", "oidc"], var.wif_type)
    error_message = "Invalid WIF type: ${var.wif_type}. Valid values are: aws, azure, gcp, oidc."
  }
}

################################################################################
# Snowflake WIF variables
################################################################################

variable "wif_role_name" {
  description = "Name of the Snowflake role to create for WIF."
  type        = string
}

variable "wif_user_name" {
  description = "Name of the Snowflake Service User to create for WIF."
  type        = string
}

variable "wif_default_warehouse" {
  description = "Default warehouse for the WIF test user/role (must exist)"
  type        = string
  default     = null
}

variable "wif_role_permissions" {
  description = "A map of objects describing the custom permissions to grant to the WIF role. Note that for schemas, the name must be in DATABASE.SCHEMA format."
  type = map(object({
    type        = string       # one of "database", "schema", "warehouse"
    name        = string       # name of the database, schema, or warehouse. Schema must be in DB.SCHEMA format.
    permissions = list(string) # list of permissions to grant
  }))
  default = {}
}

################################################################################
# AWS WIF variables
################################################################################

variable "aws_role_arn" {
  description = "ARN of the AWS role to use for WIF"
  type        = string
  default     = null
  validation {
    condition = var.aws_role_arn == null || can(regex(
      "^arn:aws:(iam::[0-9]{12}:(user|role)/.+|sts::[0-9]{12}:assumed_role/.+/.+)$",
      var.aws_role_arn
    ))
    error_message = "aws_role_arn must be a valid AWS ARN in one of these formats: arn:aws:iam::<account>:user/<user_name_with_path>, arn:aws:iam::<account>:role/<role_name_with_path>, or arn:aws:sts::<account>:assumed_role/<role_name>/<role_session_name>."
  }
}

################################################################################
# Azure WIF variables
################################################################################

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  default     = null
}

variable "azure_service_principal_id" {
  description = "The case-sensitive Object ID (Principal ID) of the managed identity assigned to the Azure workload."
  type        = string
  default     = null
}

################################################################################
# GCP WIF variables
################################################################################

variable "gcp_service_account_id" {
  description = "The unique ID of the GCP service account to use for WIF"
  type        = string
  default     = null
}

################################################################################
# OIDC WIF variables
################################################################################

variable "oidc_issuer_url" {
  description = "The OpenID Connect (OIDC) issuer URL."
  type        = string
  default     = null
}

variable "oidc_subject" {
  description = "The identifier of the workload that is connecting to Snowflake. The format of the value is specific to the OIDC provider that is issuing the attestation."
  type        = string
  default     = null
}

variable "oidc_audience_list" {
  description = "Specifies which values must be present in the aud claim of the ID token issued by the OIDC provider. Snowflake accepts the attestation if the aud claim contains at least one of the specified audiences."
  type        = list(string)
  default     = ["snowflakecomputing.com"]
}
