# --- GCP outputs ---

output "vm_name" {
  description = "Name of the GCE VM"
  value       = google_compute_instance.this.name
}

output "vm_zone" {
  description = "Zone of the GCE VM"
  value       = google_compute_instance.this.zone
}

output "vm_internal_ip" {
  description = "Internal IP address of the GCE VM"
  value       = google_compute_instance.this.network_interface[0].network_ip
}

output "vm_external_ip" {
  description = "External IP address of the GCE VM (if enabled)"
  value = (
    var.enable_external_ip && length(google_compute_instance.this.network_interface[0].access_config) > 0
    ? google_compute_instance.this.network_interface[0].access_config[0].nat_ip
    : null
  )
}

output "service_account_email" {
  description = "Email of the GCP service account attached to the VM"
  value       = google_service_account.this.email
}

output "service_account_unique_id" {
  description = "Numeric unique_id of the GCP service account. This is the value used as the Snowflake WIF SUBJECT."
  value       = google_service_account.this.unique_id
}

output "gcloud_ssh_command" {
  description = "gcloud command to SSH into the VM (uses IAP tunnel if no external IP)"
  value       = "gcloud compute ssh ${var.admin_username}@${google_compute_instance.this.name} --zone=${google_compute_instance.this.zone} --project=${var.gcp_project_id}${var.enable_external_ip ? "" : " --tunnel-through-iap"}"
}

output "ssh_command" {
  description = "Plain SSH command to connect to the VM via its external IP using the key at ssh_public_key_path. Empty when no external IP is assigned."
  value = (
    var.enable_external_ip && length(google_compute_instance.this.network_interface[0].access_config) > 0
    ? "ssh -i ${replace(var.ssh_public_key_path, ".pub", "")} ${var.admin_username}@${google_compute_instance.this.network_interface[0].access_config[0].nat_ip}"
    : ""
  )
}

# --- Snowflake outputs ---

output "snowflake_account_name" {
  description = "Snowflake account name used for provider/resources"
  value       = var.snowflake_account_name
}

output "wif_gcp_sa_id_effective" {
  description = "GCP service account unique_id mapped to the Snowflake WIF user"
  value       = local.wif_gcp_sa_id_effective
}

output "wif_test_role" {
  description = "Snowflake role created for WIF testing"
  value       = module.snowflake_wif_role.wif_role_name
}

# --- Convenience outputs ---

output "z_test_instructions" {
  description = "Instructions for testing the WIF connection"
  value       = <<-EOT

    === Snowflake WIF Test Instructions (GCP) ===

    1. Connect to the VM:
       ${var.enable_external_ip && var.ssh_public_key_path != "" ? "ssh -i ${replace(var.ssh_public_key_path, ".pub", "")} ${var.admin_username}@${var.enable_external_ip && length(google_compute_instance.this.network_interface[0].access_config) > 0 ? google_compute_instance.this.network_interface[0].access_config[0].nat_ip : "<no-external-ip>"}" : "gcloud compute ssh ${var.admin_username}@${google_compute_instance.this.name} --zone=${google_compute_instance.this.zone} --project=${var.gcp_project_id}${var.enable_external_ip ? "" : " --tunnel-through-iap"}"}

    2. Once connected, run:
       sudo -i

       # The Google guest agent runs /var/log/snowflake-test-bootstrap.log
       # to install cloud-init, then cloud-init runs the rest of the setup.
       # Wait for both to finish:
       tail -F /var/log/snowflake-test-bootstrap.log   # exits with `cloud-init bootstrap finished.`
       cloud-init status --wait                        # blocks until cloud-init is done
       # Or check: /var/lib/snowflake-test/.cloud-init-bootstrap.done exists
       #           /opt/snowflake-test/cloud-init-still-running.txt is removed

       test-snowflake-wif

       # Or manually:
       source /opt/snowflake-test/venv/bin/activate
       python3 /opt/snowflake-test/test_snowflake.py

    3. The test script will:
       - Use the VM's attached service account to obtain a Google identity token
       - Authenticate to Snowflake using WIF
       - Execute test queries to verify connectivity

    === Configuration Details ===
    Snowflake Account:        ${var.snowflake_organization_name}-${var.snowflake_account_name}
    WIF User:                 ${module.snowflake_wif_role.wif_user_name}
    WIF Role:                 ${module.snowflake_wif_role.wif_role_name}
    GCP Project:              ${var.gcp_project_id}
    Service Account email:    ${google_service_account.this.email}
    Service Account unique_id: ${local.wif_gcp_sa_id_effective}

  EOT
}
