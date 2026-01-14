output "wif_role_name" {
  value       = snowflake_account_role.wif.name
  description = "Name of the Snowflake role created for WIF."
}
