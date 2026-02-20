# v0.3.0 ➞ v0.4.0
removed {
  from = snowflake_execute.wif_workload_identity
  lifecycle {
    destroy = false
  }
}

# v0.2.0 ➞ v0.3.0
moved {
  from = snowflake_account_role.wif_test_role
  to   = snowflake_account_role.wif
}
