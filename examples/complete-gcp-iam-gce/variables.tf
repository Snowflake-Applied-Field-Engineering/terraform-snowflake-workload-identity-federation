################################################################################
# General
################################################################################

variable "name_prefix" {
  description = "Prefix to apply to resource names. Note that hyphens will be replaced with underscores for Snowflake role and user names."
  type        = string
  default     = "snow-tf-wif-test-gcp"
}

variable "labels" {
  description = "Map of labels to apply to all GCP resources. Label keys/values must conform to GCP label restrictions (lowercase, hyphens/underscores)."
  type        = map(string)
  default     = {}
}

################################################################################
# GCP Infrastructure Variables
################################################################################

variable "gcp_project_id" {
  description = "GCP Project ID to deploy resources into"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for regional resources (e.g., us-central1)"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone for the VM (e.g., us-central1-a)"
  type        = string
  default     = "us-central1-a"
}

variable "network_name" {
  description = "Name of existing VPC network to use (leave empty to create a new one)"
  type        = string
  default     = ""
}

variable "subnetwork_name" {
  description = "Name of existing subnetwork to use (leave empty to create a new one)"
  type        = string
  default     = ""
}

variable "subnet_cidr" {
  description = "Address range for subnetwork if creating new (CIDR notation)"
  type        = string
  default     = "10.20.0.0/24"
}

variable "machine_type" {
  description = "GCE machine type for the test VM"
  type        = string
  default     = "e2-small"
}

variable "vm_image" {
  description = "Source image (family) for the VM. Defaults to Debian 12."
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "enable_external_ip" {
  description = "Whether to assign an ephemeral external IP to the VM. Required if you don't have Cloud NAT or Private Google Access configured for outbound internet access (needed for pip/snowflake)."
  type        = bool
  default     = true
}

variable "allow_ssh_from_iap" {
  description = "Whether to create a firewall rule allowing SSH from Google's IAP CIDR (35.235.240.0/20). Recommended for accessing the VM via `gcloud compute ssh` without a public IP."
  type        = bool
  default     = true
}

variable "ssh_source_ranges" {
  description = "Additional CIDR ranges allowed to SSH to the VM (in addition to IAP, if enabled)."
  type        = list(string)
  default     = []
}

variable "ssh_public_key_path" {
  description = "Path to an SSH public key (e.g., ~/.ssh/id_ed25519.pub). The key is injected via instance metadata and authorized for `admin_username`. Required for plain SSH access (i.e., when not using OS Login / IAP)."
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "Linux username to create on the VM and authorize the SSH key for. Must be valid for /etc/passwd (lowercase, starts with a letter)."
  type        = string
  default     = "debian"
}

variable "enable_os_login" {
  description = "Whether to enable OS Login on the VM. OS Login requires the caller to have the roles/compute.osLogin (or osAdminLogin) IAM role on the project. If false, the `ssh-keys` metadata entry will be honored for plain SSH with the key at `ssh_public_key_path`."
  type        = bool
  default     = false
}

################################################################################
# Snowflake Variables
################################################################################

variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
}

variable "snowflake_account_name" {
  description = "Snowflake account name (e.g., xy12345)"
  type        = string
}

variable "wif_test_warehouse" {
  description = "Default warehouse for the WIF test user/role (must exist)"
  type        = string
  default     = null
}

variable "wif_test_database" {
  description = "Database to test privileges of the WIF test user/role (must exist)"
  type        = string
  default     = null
}

variable "wif_test_schema" {
  description = "Schema to test privileges of the WIF test user/role (must exist)"
  type        = string
  default     = null
}

################################################################################
# GCP WIF Identity Override
################################################################################

variable "gcp_service_account_id" {
  description = "Optional Override - GCP service account `unique_id` (numeric) to use for WIF instead of the one created by this example. If null, the service account created here will be used."
  type        = string
  default     = null
}
