module "wif_aws" {
  source = "../../"

  # Update aws_role_arn and wif_default_warehouse (must already exist!)
  # Optionally update wif_role_name and wif_user_name to change how the new resources are named.

  wif_type     = "aws"
  aws_role_arn = "arn:aws:iam::123456789012:role/example-ec2-role-with-instance-profile"

  wif_role_name              = "WIF_EXAMPLE_AWS_ROLE"
  wif_user_name              = "WIF_EXAMPLE_AWS_USER"
  wif_user_default_warehouse = "EXAMPLE_WAREHOUSE"

  # Replace EXAMPLE_DB, EXAMPLE_SCHEMA, and EXAMPLE_WAREHOUSE with your database, schema, and warehouse names.
  # Optionally modify the granted permissions.
  wif_role_permissions = {
    my_db = {
      type        = "database"
      name        = "EXAMPLE_DB"
      permissions = ["USAGE"]
    }
    my_schema = {
      type        = "schema"
      name        = "EXAMPLE_DB.EXAMPLE_SCHEMA"
      permissions = ["USAGE"]
    }
    my_warehouse = {
      type        = "warehouse"
      name        = "EXAMPLE_WAREHOUSE"
      permissions = ["USAGE"]
    }
  }
}
