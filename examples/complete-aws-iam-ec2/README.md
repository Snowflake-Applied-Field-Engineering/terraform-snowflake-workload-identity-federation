# Example:

This example creates:

- An AWS IAM role + instance profile
- A Snowflake User and Role
- Configures WIF between the two
- Deploys an EC2 instance with the instance profile
- Creates a python script at `/opt/snowflake-test/_____TODO_____` that can be used to test WIF
-

TODO - update above for accuracy
<!-- TODO proper readme -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 2.9, <= 2.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0, < 7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_iam_role"></a> [aws\_iam\_role](#module\_aws\_iam\_role) | terraform-aws-modules/iam/aws//modules/iam-role | n/a |
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | terraform-aws-modules/ec2-instance/aws | n/a |
| <a name="module_snowflake_wif_role"></a> [snowflake\_wif\_role](#module\_snowflake\_wif\_role) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Optional override AMI ID (use this if you have a golden image). If omitted, the latest x86\_64 AL2023 AMI will be used. | `string` | `null` | no |
| <a name="input_aws_role_arn"></a> [aws\_role\_arn](#input\_aws\_role\_arn) | ARN of the AWS role to use for WIF | `string` | `null` | no |
| <a name="input_azure_service_principal_id"></a> [azure\_service\_principal\_id](#input\_azure\_service\_principal\_id) | The case-sensitive Object ID (Principal ID) of the managed identity assigned to the Azure workload. | `string` | `null` | no |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | Azure tenant ID | `string` | `null` | no |
| <a name="input_gcp_service_account_id"></a> [gcp\_service\_account\_id](#input\_gcp\_service\_account\_id) | The unique ID of the GCP service account to use for WIF | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type. | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Optional EC2 key pair name (required if using SSH) | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to apply to resource names | `string` | `"snow_tf_wif_test"` | no |
| <a name="input_oidc_audience_list"></a> [oidc\_audience\_list](#input\_oidc\_audience\_list) | Specifies which values must be present in the aud claim of the ID token issued by the OIDC provider. Snowflake accepts the attestation if the aud claim contains at least one of the specified audiences. | `list(string)` | <pre>[<br/>  "snowflakecomputing.com"<br/>]</pre> | no |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | The OpenID Connect (OIDC) issuer URL. | `string` | `null` | no |
| <a name="input_oidc_subject"></a> [oidc\_subject](#input\_oidc\_subject) | The identifier of the workload that is connecting to Snowflake. The format of the value is specific to the OIDC provider that is issuing the attestation. | `string` | `null` | no |
| <a name="input_snowflake_account_name"></a> [snowflake\_account\_name](#input\_snowflake\_account\_name) | Snowflake account locator (e.g., xy12345 or xy12345.us-east-1) | `string` | n/a | yes |
| <a name="input_snowflake_organization_name"></a> [snowflake\_organization\_name](#input\_snowflake\_organization\_name) | Snowflake org name | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the test instance (private subnet recommended with SSM access) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all AWS resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Existing VPC ID where the test instance will run | `string` | n/a | yes |
| <a name="input_wif_default_warehouse"></a> [wif\_default\_warehouse](#input\_wif\_default\_warehouse) | Default warehouse for the WIF test user/role (must exist) | `string` | `null` | no |
| <a name="input_wif_role_custom_permissions"></a> [wif\_role\_custom\_permissions](#input\_wif\_role\_custom\_permissions) | A map of objects describing the custom permissions to grant to the WIF role. Note that for schemas, the name must be in DATABASE.SCHEMA format. | <pre>map(object({<br/>    type        = string       # one of "database", "schema", "warehouse"<br/>    name        = string       # name of the database, schema, or warehouse. Schema must be in DB.SCHEMA format.<br/>    permissions = list(string) # list of permissions to grant<br/>  }))</pre> | `{}` | no |
| <a name="input_wif_role_name"></a> [wif\_role\_name](#input\_wif\_role\_name) | Name of the WIF test role | `string` | `"wif"` | no |
| <a name="input_wif_test_database"></a> [wif\_test\_database](#input\_wif\_test\_database) | Database to test privileges of the WIF test user/role(must exist) | `string` | `null` | no |
| <a name="input_wif_test_schema"></a> [wif\_test\_schema](#input\_wif\_test\_schema) | Schema to test privileges of the WIF test user/role(must exist) | `string` | `null` | no |
| <a name="input_wif_type"></a> [wif\_type](#input\_wif\_type) | The type of WIF identity to create. Must be one of: aws, azure, gcp, oidc. | `string` | `"aws"` | no |
| <a name="input_wif_user_name"></a> [wif\_user\_name](#input\_wif\_user\_name) | Name of the WIF test user | `string` | `"WIF_TEST_USER"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
