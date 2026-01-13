# Migration Guide

This document is meant to help you migrate your Terraform config to the new newest version. In migration guides, we will only
describe deprecations or breaking changes and help you to change your configuration to keep the same (or similar) behavior
across different versions.

Note that this guide focuses on this Terraform module. If you choose to upgrade the version of your Snowflake Terraform Provider (or don't have it otherwise pinned), you **must** also follow the [provider migration guide](https://github.com/snowflakedb/terraform-provider-snowflake/blob/main/MIGRATION_GUIDE.md).

## v0.1.0 ➞ v0.2.0

### Breaking Changes

1. Creation of the Snowflake Service User used by WIF is now handled by the `snowflake_service_user` resource, instead of `snowflake_execute`.
   - To ensure proper upgrade, you **MUST**:
     - Remove `snowflake_execute.wif_user_create` from your state (or your existing user will be **deleted**)
     - Import your existing user to your state file
   - Reason: we now use the `snowflake_service_user` resource to create the actual user, and only use `snowflake_execute` to `SET WORKLOAD_IDENTITY` on the user (as this isn't currently supported natively by the provider). While this causes pain now, this will be needed eventually and should help ease future migrations once `snowflake_service_user` supports setting workload_identity natively.
1. The default value for several variables has changed! If you don't explicitly pass in values, you may see proposed drift during `terraform plan`.
1. The variable `var.csp` has been renamed to `var.wif_type`.
1. The variables `var.wif_test_database` and `var.wif_test_schema` have been removed from the core module to remove ambiguity. All permissions should instead be passed via `var.wif_role_permissions`.

### Other Notes

- The module now supports `"snowflakedb/snowflake" <= 2.12`. If you don't have your provider pinned, you may be prompted to update. Follow the [provider migration guide](https://github.com/snowflakedb/terraform-provider-snowflake/blob/main/MIGRATION_GUIDE.md).
- **Resource renames:** Some resources are renamed, and appropriate entries have been added to `moves.tf`.
