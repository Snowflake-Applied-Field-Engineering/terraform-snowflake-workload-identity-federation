output "snowflake_current_account" {
  description = "Account locator of the Snowflake account Terraform is connected to"
  value       = data.snowflake_current_account.this.account
}
