# output "wif_role_name" {
#   value = snowflake_account_role.wif.name
# }

# output "wif_user_name" {
#   value = snowflake_execute.wif_user_create.name
# }

# # output "wif_da" {

# # resource "snowflake_grant_privileges_to_account_role" "wif_wh_usage" {
# #   count             = var.wif_default_warehouse == null ? 0 : 1
# #   account_role_name = snowflake_account_role.wif.name
# #   privileges        = ["USAGE"]
# #   on_account_object {
# #     object_type = "WAREHOUSE"
# #     object_name = var.wif_default_warehouse
# #   }
# # }

# # resource "snowflake_grant_privileges_to_account_role" "wif_db_usage" {
# #   count             = var.wif_test_database == null ? 0 : 1
# #   account_role_name = snowflake_account_role.wif.name
# #   privileges        = ["USAGE"]
# #   on_account_object {
# #     object_type = "DATABASE"
# #     object_name = var.wif_test_database
# #   }
# # }

# # resource "snowflake_grant_privileges_to_account_role" "wif_schema_usage" {
# #   count             = var.wif_test_schema == null ? 0 : 1
# #   account_role_name = snowflake_account_role.wif.name
# #   privileges        = ["USAGE"]
# #   on_schema {
# #     schema_name = "${var.wif_test_database}.${var.wif_test_schema}"
# #   }
# # }
