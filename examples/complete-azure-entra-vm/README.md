<!-- # ❄️ Snowflake Workload Identity Federation (WIF) Test Environment (Azure)

A Terraform module to deploy a test **Azure Virtual Machine (VM)** for testing **Snowflake Workload Identity Federation (WIF)**. This enables secure authentication to Snowflake using an **Azure AD Managed Identity**, eliminating the need for password or key-based credentials.

[![Terraform Validation](https://github.com/Snowflake-Applied-Field-Engineering/snowflake-wif-azure-sp/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/Snowflake-Applied-Field-Engineering/snowflake-wif-azure-sp/actions/workflows/terraform-validate.yml)

---

## Table of Contents

- [Architecture Summary](#architecture-summary)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Cleanup](#cleanup)

---

## Architecture Summary

This module creates the following resources:

### In Azure:

* **Azure Virtual Machine (VM)** - Ubuntu 22.04 LTS VM in your specified subnet
* **User-Assigned Managed Identity** - The VM uses this identity to authenticate
* **Network Security Group (NSG)** - Minimal security rules for SSH and outbound HTTPS
* **Virtual Network & Subnet** - Creates new or uses existing VNet/subnet
* **Public IP** (Optional) - For direct SSH access to the VM

### In Snowflake:

* **Database Role** (`WIF_TEST_ROLE`) - Role with necessary permissions for testing
* **Service User** (`WIF_TEST_USER`) - Configured with Azure AD Service Principal ID to enable `WORKLOAD_IDENTITY` authentication
* **Permission Grants** - Usage permissions on warehouse, database, and schema

---

##  Prerequisites

### Required Tools

* **Terraform** >= 1.5.0
* **Azure CLI** configured and authenticated (`az login`)
* **Snowflake Account** with ACCOUNTADMIN privileges

### Required Permissions

#### Azure:
* Ability to create VMs, Managed Identities, and Network resources
* Access to Azure AD for Service Principal configuration

#### Snowflake:
* ACCOUNTADMIN role or equivalent to create users and roles
* Existing warehouse, database, and schema for testing

### Azure CLI Setup

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "your-subscription-id"

# Verify your account
az account show
```

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Snowflake-Applied-Field-Engineering/snowflake-wif-azure-sp.git
cd snowflake-wif-azure-sp
```

### 2. Configure Variables

Create a `terraform.tfvars` file with your specific values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# Azure Infrastructure
azure_subscription_id = "your-subscription-id"
azure_tenant_id       = "your-tenant-id"
location              = "eastus"
resource_group_name   = "rg-snowflake-wif-test"

# VM Configuration
vm_size        = "Standard_B2s"
admin_username = "azureuser"
ssh_public_key_path = "~/.ssh/id_rsa.pub"

# Network Security
enable_public_ip           = true
allow_ssh_from_internet    = false
ssh_source_address_prefixes = ["YOUR.IP.ADDRESS/32"]

# Snowflake Provider Authentication (for Terraform)
snowflake_organization_name = "your_org_name"
snowflake_account_name      = "your_account_locator"
snowflake_username          = "your_terraform_user"
snowflake_role              = "ACCOUNTADMIN"
snowflake_private_key_path  = "/path/to/snowflake_rsa_key.p8"

# WIF Test Resources
wif_user_name         = "WIF_TEST_USER"
wif_role_name         = "WIF_TEST_ROLE"
wif_default_warehouse = "COMPUTE_WH"
wif_test_database     = "TEST_DB"
wif_test_schema       = "PUBLIC"
```

### 3. Deploy the Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Connect and Test

After deployment, connect to the VM using one of these methods:

#### Option A: Azure CLI (Recommended)

```bash
# Get the VM name from Terraform output
VM_NAME=$(terraform output -raw vm_name)
RG_NAME=$(terraform output -raw resource_group_name)

# Connect using Azure CLI
az ssh vm -n $VM_NAME -g $RG_NAME
```

#### Option B: Direct SSH (if public IP is enabled)

```bash
# Get the public IP
PUBLIC_IP=$(terraform output -raw vm_public_ip)

# SSH to the VM
ssh azureuser@$PUBLIC_IP
```

### 5. Run the WIF Test

Once connected to the VM:

```bash
# Switch to root
sudo su -

# Run the test script (convenience command)
test-snowflake-wif

# Or manually:
source /opt/snowflake-test/venv/bin/activate
python3 /opt/snowflake-test/test_snowflake.py
```

Expected output:

```
============================================================
Snowflake WIF Connection Test (Azure)
============================================================
Snowflake Connector Version: 3.17.0

[Step 1] Obtaining Azure AD token using managed identity...
Obtaining Azure AD token for tenant: your-tenant-id
Using managed identity client ID: your-client-id
✅ Successfully obtained Azure AD token

[Step 2] Connecting to Snowflake using WIF...
Account: your-org-your-account
✅ WIF Connection established successfully!

[Step 3] Setting Snowflake context...
  ✅ Using warehouse: COMPUTE_WH
  ✅ Using database: TEST_DB
  ✅ Using schema: PUBLIC

[Step 4] Executing test queries...
  Current timestamp: 2025-10-22 15:30:45.123

============================================================
🎉 WIF Connection Successful!
============================================================
  User: WIF_TEST_USER
  Account: YOUR_ACCOUNT
  Role: WIF_TEST_ROLE
  Warehouse: COMPUTE_WH
  Database: TEST_DB
  Schema: PUBLIC
============================================================

✅ WIF test completed successfully! Connection and permissions verified.
```

---

## ⚙️ Configuration

### Network Configuration

#### Use Existing VNet/Subnet

```hcl
vnet_name   = "my-existing-vnet"
subnet_name = "my-existing-subnet"
```

#### Create New VNet/Subnet

```hcl
vnet_name             = ""  # Leave empty
subnet_name           = ""  # Leave empty
vnet_address_space    = ["10.0.0.0/16"]
subnet_address_prefix = "10.0.1.0/24"
```

### Authentication Methods

#### SSH Key Authentication (Recommended)

```hcl
ssh_public_key_path = "~/.ssh/id_rsa.pub"
```

#### Auto-Generated SSH Key

```hcl
ssh_public_key_path = ""  # Leave empty
admin_password      = null
```

The private key will be available in Terraform outputs (sensitive).

#### Password Authentication

```hcl
ssh_public_key_path = ""
admin_password      = "YourSecurePassword123!"
```

### OS Image Selection

Default is Ubuntu 22.04 LTS. To use a different image:

```hcl
os_image = {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}
```

---

##  Testing

### Manual Testing Steps

1. **Verify Managed Identity**:
   ```bash
   # On the VM
   curl -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://snowflakecomputing.com/session:scope"
   ```

2. **Check Snowflake User**:
   ```sql
   -- In Snowflake
   SHOW USERS LIKE 'WIF_TEST_USER';
   DESC USER WIF_TEST_USER;
   ```

3. **Verify Role Grants**:
   ```sql
   SHOW GRANTS TO USER WIF_TEST_USER;
   SHOW GRANTS TO ROLE WIF_TEST_ROLE;
   ```

### Automated Testing

The test script (`test_snowflake.py`) automatically:
- Obtains an Azure AD token using the managed identity
- Authenticates to Snowflake using WIF
- Executes test queries
- Verifies permissions

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Managed Identity Token Acquisition Failed

**Error**: `Failed to obtain Azure AD token`

**Solutions**:
- Verify the managed identity is assigned to the VM
- Check that the managed identity has the correct permissions
- Ensure the VM can reach Azure AD endpoints

```bash
# Verify managed identity on VM
curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq .compute.identity
```

#### 2. Snowflake Connection Failed

**Error**: `WIF Connection Failed: JWT token is invalid`

**Solutions**:
- Verify the Snowflake WIF user exists
- Check that the Azure Application ID matches the managed identity client ID
- Ensure the Azure Tenant ID is correct

```sql
-- In Snowflake, check WIF user configuration
DESC USER WIF_TEST_USER;
```

#### 3. SSH Connection Issues

**Error**: `Connection refused` or `Permission denied`

**Solutions**:
- Verify NSG rules allow SSH from your IP
- Check that the public IP is created (if `enable_public_ip = true`)
- Ensure SSH key is correctly configured

```bash
# Check NSG rules
az network nsg rule list --resource-group rg-snowflake-wif-test --nsg-name snow-wif-test-nsg --output table
```

#### 4. Insufficient Snowflake Privileges

**Error**: `Insufficient privileges to operate on warehouse`

**Solutions**:
- Grant necessary permissions to the WIF role
- Verify warehouse, database, and schema exist

```sql
-- Grant permissions
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE WIF_TEST_ROLE;
GRANT USAGE ON DATABASE TEST_DB TO ROLE WIF_TEST_ROLE;
GRANT USAGE ON SCHEMA TEST_DB.PUBLIC TO ROLE WIF_TEST_ROLE;
```

### Debugging Commands

```bash
# Check cloud-init logs
sudo cat /var/log/cloud-init-output.log

# Verify Python environment
source /opt/snowflake-test/venv/bin/activate
pip list | grep snowflake

# Test Azure identity manually
python3 -c "from azure.identity import ManagedIdentityCredential; print(ManagedIdentityCredential().get_token('https://snowflakecomputing.com/session:scope'))"
```

---

## 🔒 Security Considerations

### Best Practices

1. **Network Security**:
   - Use private subnets when possible
   - Restrict SSH access to specific IP addresses
   - Consider using Azure Bastion instead of public IPs

2. **Identity Management**:
   - Use user-assigned managed identities (not system-assigned)
   - Implement least privilege access in Snowflake
   - Regularly rotate and audit access

3. **Monitoring**:
   - Enable Azure Monitor for VM metrics
   - Configure Snowflake query history monitoring
   - Set up alerts for failed authentication attempts

4. **Compliance**:
   - Ensure all resources are tagged appropriately
   - Document WIF user purpose and ownership
   - Regular access reviews

### Production Recommendations

```hcl
# Production-ready configuration
enable_public_ip           = false  # Use private access
allow_ssh_from_internet    = false
ssh_source_address_prefixes = []    # No direct SSH

# Use Azure Bastion or VPN for access
# Implement network policies
# Enable Azure Security Center
```

---

## 🧹 Cleanup

To remove all resources:

```bash
# Destroy all Terraform-managed resources
terraform destroy

# Verify resources are deleted
az resource list --resource-group rg-snowflake-wif-test
```

**Note**: This will delete:
- Azure VM and all associated resources
- Managed identity
- Snowflake WIF user and role

---

##  Additional Resources

- [Snowflake Workload Identity Federation Documentation](https://docs.snowflake.com/en/user-guide/admin-security-fed-auth-wif)
- [Azure Managed Identities Documentation](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Snowflake Provider Documentation](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs)

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## License

This project is provided as-is for testing and demonstration purposes.

---

## Support

For issues or questions:
- Open an issue on [GitHub](https://github.com/Snowflake-Applied-Field-Engineering/snowflake-wif-azure-sp/issues)
- Contact the Snowflake Applied Field Engineering team

---

**Note**: This module is designed for testing and demonstration purposes. For production deployments, additional security hardening and compliance measures should be implemented. -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 2.9, <= 2.12 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_snowflake_wif_role"></a> [snowflake\_wif\_role](#module\_snowflake\_wif\_role) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.https_outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_subnet.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password for the VM (required if ssh\_public\_key\_path is empty) | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for the VM | `string` | `"azureuser"` | no |
| <a name="input_allow_ssh_from_internet"></a> [allow\_ssh\_from\_internet](#input\_allow\_ssh\_from\_internet) | Whether to allow SSH from internet (0.0.0.0/0) - not recommended for production | `bool` | `false` | no |
| <a name="input_azure_service_principal_id"></a> [azure\_service\_principal\_id](#input\_azure\_service\_principal\_id) | Optional Override - Azure AD Service Principal (Application) ID to use for WIF (if not provided, uses managed identity) | `string` | `""` | no |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID | `string` | n/a | yes |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | Azure AD tenant ID | `string` | n/a | yes |
| <a name="input_enable_public_ip"></a> [enable\_public\_ip](#input\_enable\_public\_ip) | Whether to create and assign a public IP to the VM | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region to deploy into (e.g., eastus, westus2) | `string` | `"eastus"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to apply to resource names | `string` | `"snow-wif-test"` | no |
| <a name="input_os_image"></a> [os\_image](#input\_os\_image) | OS image to use for VM | <pre>object({<br/>    publisher = string<br/>    offer     = string<br/>    sku       = string<br/>    version   = string<br/>  })</pre> | <pre>{<br/>  "offer": "0001-com-ubuntu-server-jammy",<br/>  "publisher": "Canonical",<br/>  "sku": "22_04-lts-gen2",<br/>  "version": "latest"<br/>}</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Azure resource group (will be created if it doesn't exist) | `string` | `"rg-snowflake-wif-test"` | no |
| <a name="input_snowflake_account_name"></a> [snowflake\_account\_name](#input\_snowflake\_account\_name) | Snowflake account locator (e.g., xy12345 or xy12345.us-east-1) | `string` | n/a | yes |
| <a name="input_snowflake_organization_name"></a> [snowflake\_organization\_name](#input\_snowflake\_organization\_name) | Snowflake organization name | `string` | n/a | yes |
| <a name="input_snowflake_private_key_passphrase"></a> [snowflake\_private\_key\_passphrase](#input\_snowflake\_private\_key\_passphrase) | Passphrase for the private key (if encrypted) | `string` | `""` | no |
| <a name="input_snowflake_private_key_path"></a> [snowflake\_private\_key\_path](#input\_snowflake\_private\_key\_path) | Path to the PKCS#8 private key for Snowflake authentication | `string` | n/a | yes |
| <a name="input_snowflake_role"></a> [snowflake\_role](#input\_snowflake\_role) | Default role to use when applying Terraform resources in Snowflake | `string` | n/a | yes |
| <a name="input_snowflake_username"></a> [snowflake\_username](#input\_snowflake\_username) | Default user to use when applying Terraform resources in Snowflake | `string` | n/a | yes |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to SSH public key for VM access (optional, leave empty for password auth) | `string` | `""` | no |
| <a name="input_ssh_source_address_prefixes"></a> [ssh\_source\_address\_prefixes](#input\_ssh\_source\_address\_prefixes) | List of CIDR blocks allowed to SSH to the VM | `list(string)` | `[]` | no |
| <a name="input_subnet_address_prefix"></a> [subnet\_address\_prefix](#input\_subnet\_address\_prefix) | Address prefix for subnet if creating new (CIDR notation) | `string` | `"10.0.1.0/24"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of existing subnet (leave empty to create new) | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size | `string` | `"Standard_B2s"` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | Address space for VNet if creating new (CIDR notation) | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of existing VNet (leave empty to create new) | `string` | `""` | no |
| <a name="input_wif_default_warehouse"></a> [wif\_default\_warehouse](#input\_wif\_default\_warehouse) | Default warehouse for the WIF test user/role (must exist) | `string` | `null` | no |
| <a name="input_wif_role_name"></a> [wif\_role\_name](#input\_wif\_role\_name) | Name of the WIF test role | `string` | `"WIF_TEST_ROLE"` | no |
| <a name="input_wif_test_database"></a> [wif\_test\_database](#input\_wif\_test\_database) | Database to test privileges of the WIF test user/role (must exist) | `string` | `null` | no |
| <a name="input_wif_test_schema"></a> [wif\_test\_schema](#input\_wif\_test\_schema) | Schema to test privileges of the WIF test user/role (must exist) | `string` | `null` | no |
| <a name="input_wif_user_name"></a> [wif\_user\_name](#input\_wif\_user\_name) | Name of the Snowflake WIF test user (e.g., WIF\_TEST\_USER) | `string` | `"WIF_TEST_USER"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_cli_ssh_command"></a> [azure\_cli\_ssh\_command](#output\_azure\_cli\_ssh\_command) | Azure CLI command to SSH into the VM |
| <a name="output_managed_identity_client_id"></a> [managed\_identity\_client\_id](#output\_managed\_identity\_client\_id) | Client ID (Application ID) of the user-assigned managed identity |
| <a name="output_managed_identity_id"></a> [managed\_identity\_id](#output\_managed\_identity\_id) | Resource ID of the user-assigned managed identity |
| <a name="output_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#output\_managed\_identity\_principal\_id) | Principal ID (Object ID) of the user-assigned managed identity |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the Azure resource group |
| <a name="output_snowflake_account_name"></a> [snowflake\_account\_name](#output\_snowflake\_account\_name) | Snowflake account locator used for provider/resources |
| <a name="output_snowflake_role_used"></a> [snowflake\_role\_used](#output\_snowflake\_role\_used) | Snowflake role leveraged by Terraform when applying resources |
| <a name="output_ssh_private_key"></a> [ssh\_private\_key](#output\_ssh\_private\_key) | Generated SSH private key (if SSH key was auto-generated) |
| <a name="output_test_instructions"></a> [test\_instructions](#output\_test\_instructions) | Instructions for testing the WIF connection |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | ID of the Azure VM |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | Name of the Azure VM |
| <a name="output_vm_private_ip"></a> [vm\_private\_ip](#output\_vm\_private\_ip) | Private IP address of the Azure VM |
| <a name="output_vm_public_ip"></a> [vm\_public\_ip](#output\_vm\_public\_ip) | Public IP address of the Azure VM (if enabled) |
| <a name="output_wif_azure_sp_id_effective"></a> [wif\_azure\_sp\_id\_effective](#output\_wif\_azure\_sp\_id\_effective) | Azure Service Principal (Application) ID mapped to the Snowflake WIF user |
| <a name="output_wif_test_role"></a> [wif\_test\_role](#output\_wif\_test\_role) | Snowflake role created for WIF testing |
<!-- END_TF_DOCS -->
