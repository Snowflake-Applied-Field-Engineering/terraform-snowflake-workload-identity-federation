# Migration Guide

This document is meant to help you migrate your Terraform config to the new newest version. In migration guides, we will only
describe deprecations or breaking changes and help you to change your configuration to keep the same (or similar) behavior
across different versions.

Note that this guide focuses on this Terraform module. If you choose to upgrade the version of your Snowflake Terraform Provider (or don't have it otherwise pinned), you **must** also follow the [provider migration guide](https://github.com/snowflakedb/terraform-provider-snowflake/blob/main/MIGRATION_GUIDE.md).

## v0.4.0 ➞ v0.5.0

### (Potenially) Breaking Changes

- The version constraint for the Snowflake Terraform provider has been loosened, changing from `~> 2.13` to `">= 2.13.0, < 2.16"`. If your provider is properly pinned at the root level, this should have minimal to no impact. If not, your Snowflake Terraform provider may get upgraded unintentionally.
  - See the [Snowflake Terraform provider migration guide](https://github.com/snowflakedb/terraform-provider-snowflake/blob/main/MIGRATION_GUIDE.md) for any breaking changes/migration notes that may apply to your environment.

## v0.3.0 ➞ v0.4.0

### Breaking Changes

- The `resource.snowflake_execute.wif_workload_identity` resource is removed, and has been superseded by the native `default_workload_identity`.
  - The existing `snowflake_execute` must be removed from the Terraform state. This can be done either manually by running `terraform state rm snowflake_execute.wif_workload_identity`, or by uncommenting the `removed` block in `migrations.tf` (requires Terraform >=v1.7).
- The `snowflakedb/snowflake` Terraform provider is now pinned to `~>2.13.0` (was: `>= 2.9, <= 2.12`). This is to allow usage of the native `default_workload_identity` block in the `snowflake_service_user`. If you must use an older version of the Terraform provider, please continue to use `v0.3.0` of this module.
  - This currently requires adding `experimental_features_enabled = ["USER_ENABLE_DEFAULT_WORKLOAD_IDENTITY"]` to your provider configuration when you invoke this module. See [the example providers.tf](./examples/basic-aws-existing-role/providers.tf)
- `moves.tf` has been renamed to `migrations.tf`.




## v0.2.0 ➞ v0.3.0

### Breaking Changes

1. `output.role_name` has changed to `output.wif_role_name` to ensure consistency with the names used for input variables.

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
