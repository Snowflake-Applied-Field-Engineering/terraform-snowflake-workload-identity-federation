terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 2.13.0, < 2.16"
    }
  }
}
