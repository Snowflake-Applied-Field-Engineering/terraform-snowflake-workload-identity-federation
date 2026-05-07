# TODO: TEST FOR OIDC (completely untested), GCP (completely untested) and AZURE (which I changed to match the docs https://docs.snowflake.com/en/sql-reference/sql/alter-user)

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

  dynamic "default_workload_identity" {
    for_each = var.wif_type == "aws" ? [1] : []
    content {
      aws {
        arn = var.aws_role_arn
      }
    }
  }

  dynamic "default_workload_identity" {
    for_each = var.wif_type == "azure" ? [1] : []
    content {
      azure {
        issuer  = "https://login.microsoftonline.com/${var.azure_tenant_id}/v2.0"
        subject = var.azure_service_principal_id
      }
    }
  }

  dynamic "default_workload_identity" {
    for_each = var.wif_type == "gcp " ? [1] : []
    content {
      gcp {
        subject = var.gcp_service_account_id
      }
    }
  }

  dynamic "default_workload_identity" {
    for_each = var.wif_type == "oidc" ? [1] : []
    content {
      oidc {
        issuer             = var.oidc_issuer_url
        subject            = var.oidc_subject
        oidc_audience_list = var.oidc_audience_list
      }
    }
  }
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
