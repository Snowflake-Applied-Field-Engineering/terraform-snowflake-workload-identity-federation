################################################################################
# Locals
################################################################################
locals {
  # Render the cloud-init configuration from the template file.
  # The template installs Python, sets up a venv, installs the Snowflake connector,
  # and writes out a test script.
  cloud_init = templatefile("${path.module}/cloud-init.yaml.tmpl", {
    test_script = templatefile("${path.module}/test_snowflake.py.tmpl", {
      snowflake_organization_name = var.snowflake_organization_name # TODO need to either get this from provider (if possible), else datasource or variable
      snowflake_account_name      = var.snowflake_account_name      # TODO need to either get this from provider (if possible), else datasource or variable
      context_setup = join("\n        ", compact([
        var.wif_test_warehouse != null ? "cur.execute(\"USE WAREHOUSE ${var.wif_test_warehouse}\")\n        print(\"  ✅ Using warehouse: ${var.wif_test_warehouse}\")" : null,
        var.wif_test_database != null ? "cur.execute(\"USE DATABASE ${var.wif_test_database}\")\n        print(\"  ✅ Using database: ${var.wif_test_database}\")" : null,
        var.wif_test_schema != null ? "cur.execute(\"USE SCHEMA ${var.wif_test_schema}\")\n        print(\"  ✅ Using schema: ${var.wif_test_schema}\")" : null
      ]))
      schema_test_query          = var.wif_test_database != null && var.wif_test_schema != null ? "try:\n            cur.execute(\"SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = '${var.wif_test_schema}'\")\n            table_count = cur.fetchone()\n            print(f\"  Tables in schema: {table_count[0]}\")\n        except Exception as e:\n            print(f\"  Schema query info: {str(e)}\")" : "# No schema test query configured"
      workload_identity_provider = "GCP"
    })
    snowflake_default_authenticator = "WORKLOAD_IDENTITY"
    snowflake_default_account       = "${var.snowflake_organization_name}-${var.snowflake_account_name}" # TODO this doesn't match how AWS module does it
    admin_username                  = var.admin_username
    ssh_authorized_key              = var.ssh_public_key_path != "" ? trimspace(file(pathexpand(var.ssh_public_key_path))) : ""
  })

  # WIF subject for GCP is the service account's numeric uniqueId.
  wif_gcp_sa_id_effective = (
    var.gcp_service_account_id == null ? google_service_account.this.unique_id : var.gcp_service_account_id
  )

  common_labels = merge(
    {
      project    = "snowflake-wif-gcp-test"
      managed-by = "terraform"
    },
    var.labels
  )

  # Derived from name_prefix; GCP service account IDs must match ^[a-z][-a-z0-9]{4,28}[a-z0-9]$
  service_account_id = substr(replace(lower(var.name_prefix), "_", "-"), 0, 30)
}

################################################################################
# Data Sources
################################################################################

# Lookup an existing network/subnetwork if the caller provided one.
data "google_compute_network" "existing" {
  count = var.network_name != "" ? 1 : 0
  name  = var.network_name
}

data "google_compute_subnetwork" "existing" {
  count  = var.subnetwork_name != "" ? 1 : 0
  name   = var.subnetwork_name
  region = var.gcp_region
}

################################################################################
# Network (created when no existing network is provided)
################################################################################

resource "google_compute_network" "this" {
  count                   = var.network_name == "" ? 1 : 0
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  count         = var.subnetwork_name == "" ? 1 : 0
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.gcp_region
  network       = var.network_name == "" ? google_compute_network.this[0].id : data.google_compute_network.existing[0].id
  # Private Google Access lets the VM reach Google APIs (including metadata) without an external IP.
  private_ip_google_access = true
}

locals {
  network_id    = var.network_name == "" ? google_compute_network.this[0].id : data.google_compute_network.existing[0].id
  network_name  = var.network_name == "" ? google_compute_network.this[0].name : data.google_compute_network.existing[0].name
  subnetwork_id = var.subnetwork_name == "" ? google_compute_subnetwork.this[0].id : data.google_compute_subnetwork.existing[0].id
}

# Firewall: allow SSH from Google IAP (so users can `gcloud compute ssh --tunnel-through-iap`).
# Reference: https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule
resource "google_compute_firewall" "allow_ssh_iap" {
  count   = var.allow_ssh_from_iap ? 1 : 0
  name    = "${var.name_prefix}-allow-ssh-iap"
  network = local.network_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["${var.name_prefix}-ssh"]
}

# Firewall: allow SSH from caller-provided ranges (optional).
resource "google_compute_firewall" "allow_ssh_custom" {
  count   = length(var.ssh_source_ranges) > 0 ? 1 : 0
  name    = "${var.name_prefix}-allow-ssh-custom"
  network = local.network_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["${var.name_prefix}-ssh"]
}

################################################################################
# Service Account
################################################################################

# The service account whose identity is federated into Snowflake.
# The Snowflake WIF subject is this account's numeric `unique_id`.
resource "google_service_account" "this" {
  account_id   = local.service_account_id
  display_name = "${var.name_prefix} Snowflake WIF test"
  description  = "Service account used to authenticate a GCE VM to Snowflake via Workload Identity Federation. Managed by Terraform."
}

################################################################################
# Snowflake WIF
################################################################################

module "snowflake_wif_role" {
  source = "../../"

  wif_type               = "gcp"
  gcp_service_account_id = local.wif_gcp_sa_id_effective

  wif_role_name              = replace(upper("${var.name_prefix}_ROLE"), "-", "_")
  wif_user_name              = replace(upper("${var.name_prefix}_USER"), "-", "_")
  wif_user_default_warehouse = var.wif_test_warehouse

  wif_role_permissions = {
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
      name        = var.wif_test_warehouse
      permissions = ["USAGE"]
    }
  }
}

################################################################################
# GCE Instance
################################################################################

resource "google_compute_instance" "this" {
  name         = "${var.name_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.gcp_zone
  tags         = ["${var.name_prefix}-ssh"]
  labels       = local.common_labels

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  network_interface {
    subnetwork = local.subnetwork_id

    # Conditional ephemeral external IP. Without this, the VM needs Cloud NAT or
    # Private Google Access + a route to PyPI for the startup-script to succeed.
    dynamic "access_config" {
      for_each = var.enable_external_ip ? [1] : []
      content {}
    }
  }

  # Attach the service account so the VM can mint identity tokens from the
  # metadata server for Snowflake WIF. The cloud-platform scope is required
  # for the identity token endpoint.
  service_account {
    email  = google_service_account.this.email
    scopes = ["cloud-platform"]
  }

  metadata = merge(
    {
      # GCE's `debian-cloud/debian-*` family does NOT ship cloud-init out of
      # the box (Ubuntu images do). We install + invoke cloud-init via a
      # tiny startup-script that the Google guest agent runs on first boot.
      # Once cloud-init is present it picks up `user-data` from the GCE
      # metadata datasource. See
      # https://cloudinit.readthedocs.io/en/latest/reference/datasources/gce.html
      startup-script = file("${path.module}/bootstrap-cloud-init.sh")
      user-data      = local.cloud_init

      # OS Login vs. metadata SSH keys are mutually exclusive: when OS Login
      # is enabled, the `ssh-keys` entry below is *ignored* and SSH access
      # requires the caller to have roles/compute.osLogin on the project.
      # Disable it to allow plain SSH via the metadata-injected key.
      enable-oslogin = var.enable_os_login ? "TRUE" : "FALSE"
    },
    # Only inject metadata SSH keys when (a) OS Login is off, and (b) a key
    # path was provided. Format is `<user>:<key contents>` (one entry per
    # newline-separated line). See
    # https://cloud.google.com/compute/docs/connect/add-ssh-keys#metadata
    !var.enable_os_login && var.ssh_public_key_path != "" ? {
      ssh-keys = "${var.admin_username}:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"
    } : {}
  )

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # If you change cloud-init, this forces a rebuild so it re-runs.
  # Comment out if you want to preserve the instance across template edits.
  # allow_stopping_for_update = true
}
