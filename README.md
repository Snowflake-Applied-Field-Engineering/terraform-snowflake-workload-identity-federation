# Snowflake Workload Identity Federation terraform Module

[![Terraform Validation](https://github.com/Snowflake-Applied-Field-Engineering/terraform-snowflake-workload-identity-federation/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/Snowflake-Applied-Field-Engineering/terraform-snowflake-workload-identity-federation/actions/workflows/terraform-validate.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This module provides a composable method to configure Workload Identity Federation for Snowflake.

## Terraform Technical Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 2.9, <= 2.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | >= 2.9, <= 2.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [snowflake_account_role.wif](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/account_role) | resource |
| [snowflake_execute.wif_workload_identity](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/execute) | resource |
| [snowflake_grant_account_role.wif_role_to_user](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.wif_db_usage](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.wif_role_custom_permissions](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.wif_schema_usage](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_grant_privileges_to_account_role.wif_wh_usage](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role) | resource |
| [snowflake_service_user.wif](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/service_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_role_arn"></a> [aws\_role\_arn](#input\_aws\_role\_arn) | ARN of the AWS role to use for WIF | `string` | `null` | no |
| <a name="input_azure_service_principal_id"></a> [azure\_service\_principal\_id](#input\_azure\_service\_principal\_id) | The case-sensitive Object ID (Principal ID) of the managed identity assigned to the Azure workload. | `string` | `null` | no |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | Azure tenant ID | `string` | `null` | no |
| <a name="input_gcp_service_account_id"></a> [gcp\_service\_account\_id](#input\_gcp\_service\_account\_id) | The unique ID of the GCP service account to use for WIF | `string` | `null` | no |
| <a name="input_oidc_audience_list"></a> [oidc\_audience\_list](#input\_oidc\_audience\_list) | Specifies which values must be present in the aud claim of the ID token issued by the OIDC provider. Snowflake accepts the attestation if the aud claim contains at least one of the specified audiences. | `list(string)` | <pre>[<br/>  "snowflakecomputing.com"<br/>]</pre> | no |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | The OpenID Connect (OIDC) issuer URL. | `string` | `null` | no |
| <a name="input_oidc_subject"></a> [oidc\_subject](#input\_oidc\_subject) | The identifier of the workload that is connecting to Snowflake. The format of the value is specific to the OIDC provider that is issuing the attestation. | `string` | `null` | no |
| <a name="input_wif_default_warehouse"></a> [wif\_default\_warehouse](#input\_wif\_default\_warehouse) | Default warehouse for the WIF test user/role (must exist) | `string` | `null` | no |
| <a name="input_wif_role_custom_permissions"></a> [wif\_role\_custom\_permissions](#input\_wif\_role\_custom\_permissions) | A map of objects describing the custom permissions to grant to the WIF role. Note that for schemas, the name must be in DATABASE.SCHEMA format. | <pre>map(object({<br/>    type        = string       # one of "database", "schema", "warehouse"<br/>    name        = string       # name of the database, schema, or warehouse. Schema must be in DB.SCHEMA format.<br/>    permissions = list(string) # list of permissions to grant<br/>  }))</pre> | `{}` | no |
| <a name="input_wif_role_name"></a> [wif\_role\_name](#input\_wif\_role\_name) | Name of the WIF test role | `string` | `"wif"` | no |
| <a name="input_wif_test_database"></a> [wif\_test\_database](#input\_wif\_test\_database) | Database to test privileges of the WIF test user/role(must exist) | `string` | `null` | no |
| <a name="input_wif_test_schema"></a> [wif\_test\_schema](#input\_wif\_test\_schema) | Schema to test privileges of the WIF test user/role(must exist) | `string` | `null` | no |
| <a name="input_wif_type"></a> [wif\_type](#input\_wif\_type) | The type of WIF identity to create. Must be one of: aws, azure, gcp, oidc. | `string` | `"aws"` | no |
| <a name="input_wif_user_name"></a> [wif\_user\_name](#input\_wif\_user\_name) | Name of the WIF test user | `string` | `"WIF_TEST_USER"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | n/a |
| <a name="output_service_user_login_name"></a> [service\_user\_login\_name](#output\_service\_user\_login\_name) | n/a |
<!-- END_TF_DOCS -->

## Development

### Prerequisites

- Terraform >= 1.5.0
- Pre-commit (optional, for git hooks)
- terraform-docs (if using pre-commit)

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

- Follow [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- Run `terraform fmt` before committing
- Ensure all validation checks pass
- Update documentation for any changes

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For questions, issues, or contributions, please open an issue on GitHub. Support is provided on a best-effort basis, and Snowflake Support is unable to assist with content in this repository.
