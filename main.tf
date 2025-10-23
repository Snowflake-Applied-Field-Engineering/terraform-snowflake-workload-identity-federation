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

# 1) Create the WIF test role in Snowflake
resource "snowflake_account_role" "wif_test_role" {
  name    = var.wif_role_name
  comment = "Role for AWS→Snowflake WIF test user (Terraform-managed)"
}

# 2) Create the WIF service user via exact SQL (TYPE=SERVICE + WORKLOAD_IDENTITY)
#    We use snowflake_execute because the snowflake_user resource does not yet
#    expose WORKLOAD_IDENTITY/TYPE=SERVICE as first-class arguments.
resource "snowflake_execute" "wif_user_create" {
  # Ensure the role exists and the AWS role ARN is resolved first
  depends_on = [
    snowflake_account_role.wif_test_role
  ]

  # CREATE (idempotent), VERIFY (query), and DESTROY (revert)
  # Note: LOGIN_NAME is not needed for WIF users - authentication is via WORKLOAD_IDENTITY
  execute = <<SQL
CREATE USER IF NOT EXISTS ${var.wif_user_name}
  TYPE = SERVICE
  DEFAULT_ROLE = ${snowflake_account_role.wif_test_role.name}
  WORKLOAD_IDENTITY = (
  ${local.workload_identity_sql_string})
  COMMENT = 'WIF service user (AWS role mapped) managed by Terraform';
SQL

  # Optional visibility during plan/apply
  query = "SHOW USERS LIKE '${var.wif_user_name}';"

  # Clean removal on destroy
  revert = "DROP USER IF EXISTS ${var.wif_user_name};"
}

# 3) Grant the WIF role to the WIF user
resource "snowflake_grant_account_role" "wif_role_to_user" {
  role_name  = snowflake_account_role.wif_test_role.name
  user_name  = var.wif_user_name
  depends_on = [snowflake_execute.wif_user_create]
}

# --- Optional: minimal usage grants so the user can run a quick query ---
# Guard each with count so nulls skip creation.

resource "snowflake_grant_privileges_to_account_role" "wif_wh_usage" {
  count             = var.wif_default_warehouse == null ? 0 : 1
  account_role_name = snowflake_account_role.wif_test_role.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.wif_default_warehouse
  }
}

resource "snowflake_grant_privileges_to_account_role" "wif_db_usage" {
  count             = var.wif_test_database == null ? 0 : 1
  account_role_name = snowflake_account_role.wif_test_role.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.wif_test_database
  }
}

resource "snowflake_grant_privileges_to_account_role" "wif_schema_usage" {
  count             = var.wif_test_schema == null ? 0 : 1
  account_role_name = snowflake_account_role.wif_test_role.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "${var.wif_test_database}.${var.wif_test_schema}"
  }
}
