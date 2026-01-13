# TODO: TEST FOR OIDC (completely untested), GCP (completely untested) and AZURE (which I changed to match the docs https://docs.snowflake.com/en/sql-reference/sql/alter-user)

################################################################################
# Locals
################################################################################

locals {
  ## Define the workload identity SQL string for each CSP
  # This is needed because the service_user resource does not yet support WORKLOAD_IDENTITY
  wi_sql_aws = var.wif_type == "aws" ? (<<EOT
    TYPE = AWS
    ARN  = '${var.aws_role_arn}'
  EOT
  ) : null

  wi_sql_azure = var.wif_type == "azure" ? (<<EOT
    TYPE = AZURE
    ISSUER = 'https://login.microsoftonline.com/${var.azure_tenant_id}/v2.0'
    SUBJECT = '${var.azure_service_principal_id}'
EOT
  ) : null

  wi_sql_gcp = var.wif_type == "gcp" ? (<<EOT
    TYPE = GCP
    SUBJECT = '${var.gcp_service_account_id}'
  EOT
  ) : null

  wi_sql_oidc = var.wif_type == "oidc" ? (<<EOT
    TYPE = OIDC
    ISSUER = '${var.oidc_issuer_url}'
    SUBJECT = '${var.oidc_subject}'
    AUDIENCE_LIST = (${join(", ", [for aud in var.oidc_audience_list : "'${aud}'"])})
  EOT
  ) : null

  workload_identity_sql_string = var.wif_type == "aws" ? local.wi_sql_aws : (var.wif_type == "azure" ? local.wi_sql_azure : (var.wif_type == "gcp" ? local.wi_sql_gcp : (var.wif_type == "oidc" ? local.wi_sql_oidc : null)))
}

################################################################################
# Snowflake Resources
################################################################################

# Create the WIF role and user in Snowflake
resource "snowflake_account_role" "wif" {
  name    = var.wif_role_name
  comment = "Role for WIF Access to Snowflake. Managed by Terraform."
}

resource "snowflake_service_user" "wif" {
  name              = var.wif_user_name
  comment           = "User for WIF access to Snowflake. Managed by Terraform."
  default_role      = snowflake_account_role.wif.name
  default_warehouse = var.wif_user_default_warehouse
  network_policy    = var.wif_user_network_policy_name
  # TODO: Once supported, add workload_identity here instead of using snowflake_execute below
}

# The WORKLOAD_IDENTITY property is not supported in service_user resource as of provider v2.12, so we use execute
resource "snowflake_execute" "wif_workload_identity" {
  execute = "ALTER USER ${var.wif_user_name} SET WORKLOAD_IDENTITY = (${local.workload_identity_sql_string});"
  revert  = "ALTER USER ${var.wif_user_name} UNSET WORKLOAD_IDENTITY;"

  depends_on = [snowflake_service_user.wif]
}

# Grant the WIF role to the service user
resource "snowflake_grant_account_role" "wif_role_to_user" {
  role_name = snowflake_account_role.wif.name
  user_name = snowflake_service_user.wif.name
}

# Grant permissions to the WIF role
resource "snowflake_grant_privileges_to_account_role" "wif_role_permissions" {
  for_each          = var.wif_role_permissions
  account_role_name = snowflake_account_role.wif.name
  privileges        = each.value.permissions

  dynamic "on_account_object" { # database or warehouse
    for_each = upper(each.value.type) == "DATABASE" || upper(each.value.type) == "WAREHOUSE" ? [1] : []
    content {
      object_type = upper(each.value.type)
      object_name = each.value.name
    }
  }
  dynamic "on_schema" {
    for_each = upper(each.value.type) == "SCHEMA" ? [1] : []
    content {
      schema_name = each.value.name
    }
  }
}
