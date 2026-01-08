################################################################################
# Locals
################################################################################
locals {
  # Render the EC2 user_data from the template file.
  # The template installs Python, sets up a venv, installs the Snowflake connector,
  # and writes out a test script.
  user_data = templatefile("${path.module}/userdata.sh.tmpl", {
    test_script = templatefile("${path.module}/test_snowflake.py.tmpl", {
      snowflake_organization_name = var.snowflake_organization_name # TODO need to either get this from provider (if possible), else datasource or variable
      snowflake_account_name      = var.snowflake_account_name      # TODO need to either get this from provider (if possible), else datasource or variable
      context_setup = join("\n        ", compact([
        var.wif_default_warehouse != null ? "cur.execute(\"USE WAREHOUSE ${var.wif_default_warehouse}\")\n        print(\"  ✅ Using warehouse: ${var.wif_default_warehouse}\")" : null,
        var.wif_test_database != null ? "cur.execute(\"USE DATABASE ${var.wif_test_database}\")\n        print(\"  ✅ Using database: ${var.wif_test_database}\")" : null,
        var.wif_test_schema != null ? "cur.execute(\"USE SCHEMA ${var.wif_test_schema}\")\n        print(\"  ✅ Using schema: ${var.wif_test_schema}\")" : null
      ]))
      schema_test_query = var.wif_test_database != null && var.wif_test_schema != null ? "try:\n            cur.execute(\"SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = '${var.wif_test_schema}'\")\n            table_count = cur.fetchone()\n            print(f\"  Tables in schema: {table_count[0]}\")\n        except Exception as e:\n            print(f\"  Schema query info: {str(e)}\")" : "# No schema test query configured"
    })
    snowflake_default_authenticator = "WORKLOAD_IDENTITY"
    snowflake_account_name          = var.snowflake_account_name # TODO need to either get this from provider (if possible), else datasource or variable
  })

  # AMI Selection
  # ami_id = var.ami_id == null ? data.aws_ssm_parameter.ami_id[0].value : var.ami_id
  # ami_ssm_param_al2023_arm64 = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
  # ami_ssm_param_al2023_x86_64 = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  # ami_ssm_param_ubuntu_2404_amd64 = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
  # ami_ssm_param_ubuntu_2404_arm64 = "/aws/service/canonical/ubuntu/server/24.04/stable/current/arm64/hvm/ebs-gp3/ami-id"

  # Convenience name tags
  common_tags = merge(
    {
      Project   = "snowflake-wif-ec2-test",
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

################################################################################
# Data Sources
################################################################################

data "aws_region" "current" {}

################################################################################
# Main
################################################################################

module "aws_iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"

  name                    = "${var.name_prefix}_role"
  create_instance_profile = true

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole",
      ]
      principals = [{
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }]
    }
  }

  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-ec2"
    },
    local.common_tags
  )
}


module "snowflake_wif_role" {
  source = "../../"

  wif_type     = "aws"
  aws_role_arn = module.aws_iam_role.arn

  wif_default_warehouse = var.wif_default_warehouse
  wif_role_name         = upper("${var.name_prefix}_ROLE")
  wif_user_name         = upper("${var.name_prefix}_USER")

  # Replace EXAMPLE_DB, EXAMPLE_SCHEMA, and EXAMPLE_WAREHOUSE with your database, schema, and warehouse names.
  # Optionally modify the granted permissions.
  wif_role_custom_permissions = {
    my_db = {
      type        = "database"
      name        = var.wif_test_database
      permissions = ["USAGE"]
    }
    my_schema = {
      type        = "schema"
      name        = "${var.wif_test_database}.${var.wif_test_schema}"
      permissions = ["USAGE"]
    }
    my_warehouse = {
      type        = "warehouse"
      name        = var.wif_default_warehouse
      permissions = ["USAGE"]
    }
  }
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  # version = "6.1.4"

  name = var.name_prefix

  # Pass in only one of ami or ami_ssm_parameter
  ami               = var.ami_id == null ? null : var.ami_id
  ami_ssm_parameter = var.ami_id == null ? "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" : null
  instance_type     = var.instance_type

  subnet_id = var.subnet_id

  iam_instance_profile = module.aws_iam_role.instance_profile_name
  user_data_base64     = base64encode(local.user_data)
  # user_data_replace_on_change = true

  # Enforce IMDSv2 and increase hop limit # TODO WHY increase? Not using docker
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  key_name = var.key_name

  enable_volume_tags = true
  root_block_device = {
    encrypted = true
    type      = "gp3"
  }

  security_group_description = "Security group for Snowflake WIF EC2 instance."
  security_group_egress_rules = {
    https_outbound = {
      description = "Outbound HTTPS for package management, Snowflake API, and SSM endpoints"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    },
    http_outbound = {
      description = "Outbound HTTP for package management (temporary - consider removing after initial setup)"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    },
    ntp_outbound = {
      description = "Outbound NTP for time synchronization"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "udp"
      from_port   = 123
      to_port     = 123
    }
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-ec2"
    },
    local.common_tags
  )
}
