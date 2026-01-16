# Azure Resource Manager Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }
  }
  subscription_id = var.azure_subscription_id
}

# Azure Active Directory Provider
provider "azuread" {
  tenant_id = var.azure_tenant_id
}

# Snowflake Provider
# You must configure the provider through either environment variables or in the terraform configuration file below.
# Environment variables keep the Terraform more portable, hardcoded (or variable-based) config makes it more declarative
# For more details, see https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs

provider "snowflake" {
  ### Option A: Environment Variables (current configuration)
  ## Substitute in the appropriate values for the environment variables and run the following in your terminal:
  # export SNOWFLAKE_ACCOUNT_NAME="REPLACE_ME"
  # export SNOWFLAKE_AUTHENTICATOR="SNOWFLAKE_JWT" # For Key-pair authentication
  # export SNOWFLAKE_ORGANIZATION_NAME="REPLACE_ME"
  # export SNOWFLAKE_PRIVATE_KEY=$(cat ~/path/to/REPLACE_ME.p8)
  # export SNOWFLAKE_ROLE="REPLACE_ME"
  # export SNOWFLAKE_USER="REPLACE_ME"

  ### Option B: Snowflake Terraform Profile
  ## Configured in ~/.snowflake/config (Terraform-specific config that is similar to snowcli config)
  ## See https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs#toml-file for more details
  ## Then uncomment the line below and update with your profile name.
  # profile = "MY_SNOWFLAKE_PROFILE"

  ## Other methods are available, see https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs#authentication for more details.
}
