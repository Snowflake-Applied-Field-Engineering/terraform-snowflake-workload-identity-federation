# outputs.tf
# Output value declarations

# Example outputs
# output "id" {
#   description = "The ID of the created resource"
#   value       = resource_type.this.id
# }

# output "arn" {
#   description = "The ARN of the created resource"
#   value       = resource_type.this.arn
# }

# output "name" {
#   description = "The name of the created resource"
#   value       = resource_type.this.name
# }

# Snowflake-specific outputs
# output "database_name" {
#   description = "Name of the Snowflake database"
#   value       = snowflake_database.this.name
# }

# output "database_id" {
#   description = "ID of the Snowflake database"
#   value       = snowflake_database.this.id
# }

# Complex output example
# output "connection_info" {
#   description = "Connection information for the resource"
#   value = {
#     endpoint = resource_type.this.endpoint
#     port     = resource_type.this.port
#     protocol = resource_type.this.protocol
#   }
# }

# Sensitive output example
# output "credentials" {
#   description = "Credentials for accessing the resource"
#   value       = resource_type.this.credentials
#   sensitive   = true
# }

# Add your output definitions here
