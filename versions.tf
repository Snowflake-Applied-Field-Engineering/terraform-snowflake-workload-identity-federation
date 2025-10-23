terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.9" #! todo update to 2.9
    }
  }
}
