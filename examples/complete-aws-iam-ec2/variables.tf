################################################################################
# General
################################################################################

variable "name_prefix" {
  description = "Prefix to apply to resource names"
  type        = string
  default     = "snow_tf_wif_test"
}

################################################################################
# AWS Variables
################################################################################

variable "ami_id" {
  description = "Optional override AMI ID (use this if you have a golden image). If omitted, the latest x86_64 AL2023 AMI will be used."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "Existing VPC ID where the test instance will run"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the test instance (private subnet recommended with SSM access)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional EC2 key pair name (required if using SSH)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to apply to all AWS resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Snowflake Variables
################################################################################

variable "snowflake_account_name" {
  description = "Snowflake account locator (e.g., xy12345 or xy12345.us-east-1)"
  type        = string
}

variable "snowflake_organization_name" {
  description = "Snowflake org name"
  type        = string
}

variable "wif_test_warehouse" {
  description = "Warehouse for the WIF test user/role (must exist)"
  type        = string
  default     = null
}

variable "wif_test_database" {
  description = "Database to test privileges of the WIF test user/role(must exist)"
  type        = string
  default     = null
}

variable "wif_test_schema" {
  description = "Schema to test privileges of the WIF test user/role(must exist)"
  type        = string
  default     = null
}
