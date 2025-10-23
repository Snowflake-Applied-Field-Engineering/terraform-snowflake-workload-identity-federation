# Snowflake Provider
# You must configure the provider through either environment variables or in the terraform configuration file below.
# Environment variables keep the Terraform more portable, hardcoded (or variable-based) config makes it more declarative
# For more details, see https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs

## Authentication Options:
## TODO examples for all
# Option A: Environment Variables (current configuration)
# Option B: Key-pair authentication
# Option C: OAuth
# Option D: Snowflake Terraform Profile

# TODO pick how want to handle this by default

# Option A: Environment Variables (current configuration)
provider "snowflake" {
  ## Substitute in the appropriate values for the environment variables and run the following in your terminal:
  # export SNOWFLAKE_ACCOUNT_NAME="REPLACE_ME"
  # export SNOWFLAKE_AUTHENTICATOR="SNOWFLAKE_JWT" # For Key-pair authentication
  # export SNOWFLAKE_ORGANIZATION_NAME="REPLACE_ME"
  # export SNOWFLAKE_PRIVATE_KEY=$(cat ~/path/to/REPLACE_ME.p8)
  # export SNOWFLAKE_ROLE="REPLACE_ME"
  # export SNOWFLAKE_USER="REPLACE_ME"
}

## Option B: Key-pair authentication
# provider "snowflake" {
#   # organization_name = var.snowflake_organization_name
#   # account_name      = var.snowflake_account_name
#   # user              = var.snowflake_username
#   # role              = var.snowflake_role
#   # authenticator     = "SNOWFLAKE_JWT" # Requires private_key and corresponding public key setup
#   # private_key       = file(var.snowflake_private_key_path)
# }
