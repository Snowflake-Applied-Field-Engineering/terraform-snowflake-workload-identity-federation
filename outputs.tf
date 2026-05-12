output "wif_role_name" {
  value       = snowflake_account_role.wif.name
  description = "Name of the Snowflake role created for WIF."
}

output "wif_user_name" {
  value       = snowflake_service_user.wif.name
  description = "Name of the Snowflake service user created for WIF."
}
