# locals.tf
# Local value definitions

locals {
  # Common tags to apply to all resources
  # common_tags = merge(
  #   var.tags,
  #   {
  #     ManagedBy   = "Terraform"
  #     Module      = "terraform-module-template"
  #     Environment = var.environment
  #   }
  # )

  # Name prefix for resources
  # name_prefix = "${var.environment}-${var.name}"

  # Conditional logic examples
  # enable_feature = var.environment == "prod" ? true : false

  # String manipulation
  # normalized_name = lower(replace(var.name, " ", "-"))

  # Complex transformations
  # subnet_map = {
  #   for subnet in var.subnets :
  #   subnet.name => subnet.cidr_block
  # }

  # Add your local value definitions here
}
