################################################################################
# Locals
################################################################################
# locals.tf

locals {
  # Render the cloud-init configuration from the template file.
  # The template installs Python, sets up a venv, installs the Snowflake connector,
  # and writes out a test script.
  cloud_init = templatefile("${path.module}/cloud-init.yaml.tmpl", {
    test_script = templatefile("${path.module}/test_snowflake.py.tmpl", {
      snowflake_organization_name = var.snowflake_organization_name
      snowflake_account_name      = var.snowflake_account_name
      azure_tenant_id             = var.azure_tenant_id
      azure_client_id             = local.wif_azure_sp_id_effective
      context_setup = join("\n        ", compact([
        var.wif_default_warehouse != null ? "cur.execute(\"USE WAREHOUSE ${var.wif_default_warehouse}\")\n        print(\"  ✅ Using warehouse: ${var.wif_default_warehouse}\")" : null,
        var.wif_test_database != null ? "cur.execute(\"USE DATABASE ${var.wif_test_database}\")\n        print(\"  ✅ Using database: ${var.wif_test_database}\")" : null,
        var.wif_test_schema != null ? "cur.execute(\"USE SCHEMA ${var.wif_test_schema}\")\n        print(\"  ✅ Using schema: ${var.wif_test_schema}\")" : null
      ]))
      schema_test_query = var.wif_test_database != null && var.wif_test_schema != null ? "try:\n            cur.execute(\"SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = '${var.wif_test_schema}'\")\n            table_count = cur.fetchone()\n            print(f\"  Tables in schema: {table_count[0]}\")\n        except Exception as e:\n            print(f\"  Schema query info: {str(e)}\")" : "# No schema test query configured"
    })
    snowflake_default_authenticator = "WORKLOAD_IDENTITY"
    snowflake_default_account       = "${var.snowflake_organization_name}-${var.snowflake_account_name}"
    azure_tenant_id                 = var.azure_tenant_id
  })


  wif_azure_sp_id_effective = (
    var.azure_service_principal_id != "" ? var.azure_service_principal_id : azurerm_user_assigned_identity.this.client_id
  )
  # wif_azure_tenant_id = var.azure_tenant_id

  # Convenience name tags
  common_tags = merge(
    {
      Project     = "snowflake-wif-azure-test"
      Environment = "test"
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

################################################################################
# Data Sources
################################################################################

# data "aws_region" "current" {}

################################################################################
# Main
################################################################################

# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "this" {
  name                = "${var.name_prefix}-identity"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

module "snowflake_wif_role" {
  source = "../../"

  wif_type                   = "azure"
  azure_service_principal_id = local.wif_azure_sp_id_effective
  azure_tenant_id            = var.azure_tenant_id

  wif_role_name              = upper("${var.name_prefix}_ROLE")
  wif_user_name              = upper("${var.name_prefix}_USER")
  wif_user_default_warehouse = var.wif_default_warehouse

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
      name        = var.wif_default_warehouse
      permissions = ["USAGE"]
    }
  }
}

# Azure infrastructure resources for Snowflake WIF testing

# Resource Group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Virtual Network (create new or use existing)
resource "azurerm_virtual_network" "this" {
  count               = var.vnet_name == "" ? 1 : 0
  name                = "${var.name_prefix}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

data "azurerm_virtual_network" "existing" {
  count               = var.vnet_name != "" ? 1 : 0
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.this.name
}

locals {
  vnet_name = var.vnet_name != "" ? data.azurerm_virtual_network.existing[0].name : azurerm_virtual_network.this[0].name
  vnet_id   = var.vnet_name != "" ? data.azurerm_virtual_network.existing[0].id : azurerm_virtual_network.this[0].id
}

# Subnet (create new or use existing)
resource "azurerm_subnet" "this" {
  count                = var.subnet_name == "" ? 1 : 0
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = local.vnet_name
  address_prefixes     = [var.subnet_address_prefix]
}

data "azurerm_subnet" "existing" {
  count                = var.subnet_name != "" ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = azurerm_resource_group.this.name
}

locals {
  subnet_id = var.subnet_name != "" ? data.azurerm_subnet.existing[0].id : azurerm_subnet.this[0].id
}

# Network Security Group
resource "azurerm_network_security_group" "this" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

# NSG Rule: Allow SSH (conditional)
resource "azurerm_network_security_rule" "ssh" {
  count                       = var.allow_ssh_from_internet || length(var.ssh_source_address_prefixes) > 0 ? 1 : 0
  name                        = "AllowSSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.allow_ssh_from_internet ? ["0.0.0.0/0"] : var.ssh_source_address_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name
}

# NSG Rule: Allow outbound HTTPS for Snowflake
resource "azurerm_network_security_rule" "https_outbound" {
  name                        = "AllowHTTPSOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Public IP (optional)
resource "azurerm_public_ip" "this" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "${var.name_prefix}-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# Network Interface
resource "azurerm_network_interface" "this" {
  name                = "${var.name_prefix}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.this[0].id : null
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "this" {
  name                = "${var.name_prefix}-vm"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = local.common_tags

  # Assign the managed identity to the VM
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  # SSH or Password authentication
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key_path != "" ? file(var.ssh_public_key_path) : tls_private_key.ssh[0].public_key_openssh
  }

  disable_password_authentication = var.ssh_public_key_path != "" || var.admin_password == null

  os_disk {
    name                 = "${var.name_prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version
  }

  # Cloud-init configuration
  custom_data = base64encode(local.cloud_init)

  # Boot diagnostics
  boot_diagnostics {
    storage_account_uri = null # Uses managed storage account
  }
}

# Generate SSH key if not provided
resource "tls_private_key" "ssh" {
  count     = var.ssh_public_key_path == "" && var.admin_password == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}


# module "azure_vm" {
#   source  = "Azure/avm-res-compute-virtualmachine/azurerm"
#   version = "0.20.0"
#   # insert the 5 required variables here
# }
