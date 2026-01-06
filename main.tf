# TODO
# * remove the word "test" from everywhere in the codebase
# * add outputs
# * allow for custom permissions for db/schema/warehouse
# * allow for network policy to be applied to the WIF user

################################################################################
# Locals
################################################################################

locals {
  wi_sql_aws = var.csp == "aws" ? (<<EOT
    TYPE = AWS
    ARN  = '${var.aws_role_arn}'
  EOT
  ) : null

  wi_sql_azure = var.csp == "azure" ? (<<EOT
    TYPE = AZURE
    AZURE_TENANT_ID = '${var.azure_tenant_id}'
    AZURE_APPLICATION_ID = '${var.azure_sp_id}'
EOT
  ) : null

  wi_sql_gcp = var.csp == "gcp" ? (<<EOT
  #! TODO
  EOT
  ) : null

  workload_identity_sql_string = var.csp == "aws" ? local.wi_sql_aws : (var.csp == "azure" ? local.wi_sql_azure : (var.csp == "gcp" ? local.wi_sql_gcp : null))
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
  name         = var.wif_user_name
  comment      = "WIF service user mapped to role/service principal in ${var.csp}. Managed by Terraform."
  default_role = snowflake_account_role.wif.name
  # TODO: Once supported, add workload_identity here instead of using snowflake_execute below
}

# WORKLOAD_IDENTITY not supported in service_user resource as of provider v2.12, so we use execute
resource "snowflake_execute" "wif_workload_identity" {
  execute = <<SQL
ALTER USER ${var.wif_user_name} SET WORKLOAD_IDENTITY = (
  ${local.workload_identity_sql_string})
SQL

  revert = "ALTER USER ${var.wif_user_name} UNSET WORKLOAD_IDENTITY;"

  depends_on = [snowflake_service_user.wif] # needed because passing in var above, not resource
}

# Grant the WIF role to the service user
resource "snowflake_grant_account_role" "wif_role_to_user" {
  role_name = snowflake_account_role.wif.name
  user_name = snowflake_service_user.wif.name
}

# --- Optional: minimal usage grants so the user can run a quick query ---
# Guard each with count so nulls skip creation.

resource "snowflake_grant_privileges_to_account_role" "wif_wh_usage" {
  count             = var.wif_default_warehouse == null ? 0 : 1
  account_role_name = snowflake_account_role.wif.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.wif_default_warehouse
  }
}

resource "snowflake_grant_privileges_to_account_role" "wif_db_usage" {
  count             = var.wif_test_database == null ? 0 : 1
  account_role_name = snowflake_account_role.wif.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.wif_test_database
  }
}

resource "snowflake_grant_privileges_to_account_role" "wif_schema_usage" {
  count             = var.wif_test_schema == null ? 0 : 1
  account_role_name = snowflake_account_role.wif.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "${var.wif_test_database}.${var.wif_test_schema}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "wif_role_custom_permissions" {
  for_each          = var.wif_role_custom_permissions
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
