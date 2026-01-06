output "role_name" {
  value = snowflake_account_role.wif.name
}

output "service_user_login_name" {
  value = snowflake_service_user.wif.login_name
}
