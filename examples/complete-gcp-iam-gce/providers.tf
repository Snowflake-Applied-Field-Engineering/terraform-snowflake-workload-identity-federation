# Google Cloud Provider
# Authenticate with one of:
#   - `gcloud auth application-default login` (recommended for local development)
#   - GOOGLE_APPLICATION_CREDENTIALS environment variable pointing to a key file
#   - Workload Identity (when running from another GCP workload)
# See https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# Snowflake Provider
# You must configure the provider through either environment variables or in the terraform configuration file below.
# Environment variables keep the Terraform more portable, hardcoded (or variable-based) config makes it more declarative
# For more details, see https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs

provider "snowflake" {
  experimental_features_enabled = ["USER_ENABLE_DEFAULT_WORKLOAD_IDENTITY"]

  ### Authentication Options:
  # Option A: Environment Variables (current configuration)
  # Option B: Key-pair authentication
  # Option C: OAuth
  # Option D: Snowflake Terraform Profile

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
