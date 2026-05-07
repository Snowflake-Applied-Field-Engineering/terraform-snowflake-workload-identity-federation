# v0.3.0 ➞ v0.4.0
# removed { # Disabled by default in v0.4.1, in case terraform version is <1.7
#   from = snowflake_execute.wif_workload_identity
#   lifecycle {
#     destroy = false
#   }
# }

# v0.2.0 ➞ v0.3.0
moved {
  from = snowflake_account_role.wif_test_role
  to   = snowflake_account_role.wif
}
