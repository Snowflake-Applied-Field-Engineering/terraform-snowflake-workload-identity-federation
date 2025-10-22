# Terraform Module Template - Usage Guide

This guide explains how to use this template to create new Terraform modules for Snowflake and other cloud providers.

## 🎯 What This Template Provides

### Core Structure
- **Standardized file organization** following Terraform best practices
- **Automated validation** via GitHub Actions
- **Pre-commit hooks** for code quality
- **Documentation templates** for consistent documentation
- **Example configurations** (basic and advanced)
- **Testing framework setup** for Terratest or native Terraform tests

### Files Included

```
terraform-module-template/
├── .github/
│   ├── workflows/
│   │   └── terraform-validate.yml    # Automated CI/CD validation
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md             # Bug report template
│   │   └── feature_request.md        # Feature request template
│   └── pull_request_template.md      # PR template
├── examples/
│   ├── basic/                        # Basic usage example
│   └── advanced/                     # Advanced usage example
├── tests/                            # Test directory
│   └── README.md                     # Testing guide
├── main.tf                           # Main resource definitions
├── variables.tf                      # Input variables
├── outputs.tf                        # Output values
├── versions.tf                       # Provider versions
├── locals.tf                         # Local values
├── data.tf                           # Data sources
├── README.md                         # Main documentation
├── LICENSE                           # Apache 2.0 license
├── CONTRIBUTING.md                   # Contribution guidelines
├── CHANGELOG.md                      # Version history
├── .gitignore                        # Git ignore patterns
└── .pre-commit-config.yaml           # Pre-commit hooks

```

## 🚀 Quick Start: Creating a New Module

### 1. Create from Template

**Option A: Via GitHub UI**
1. Go to https://github.com/Snowflake-Applied-Field-Engineering/terraform-module-template
2. Click "Use this template" button
3. Name your new repository (e.g., `terraform-snowflake-database`)
4. Clone your new repository

**Option B: Via Command Line**
```bash
# Clone the template
git clone https://github.com/Snowflake-Applied-Field-Engineering/terraform-module-template.git my-new-module
cd my-new-module

# Remove git history and start fresh
rm -rf .git
git init
git add .
git commit -m "Initial commit from template"

# Connect to your new repository
git remote add origin https://github.com/YOUR-ORG/your-new-module.git
git push -u origin main
```

### 2. Customize for Your Module

#### Update README.md
Replace the template content with your module's information:
- Module name and description
- What resources it creates
- Usage examples
- Input/output tables

#### Update main.tf
Add your resource definitions:
```hcl
resource "snowflake_database" "this" {
  name    = var.database_name
  comment = var.comment

  data_retention_time_in_days = var.data_retention_days
}
```

#### Update variables.tf
Define your input variables:
```hcl
variable "database_name" {
  description = "Name of the Snowflake database"
  type        = string

  validation {
    condition     = length(var.database_name) > 0
    error_message = "Database name must not be empty."
  }
}
```

#### Update outputs.tf
Define your outputs:
```hcl
output "database_id" {
  description = "The ID of the created database"
  value       = snowflake_database.this.id
}
```

#### Update versions.tf
Adjust provider versions as needed:
```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.94"
    }
  }
}
```

### 3. Create Examples

#### Basic Example (examples/basic/)
Create a simple, working example:
```hcl
module "database" {
  source = "../../"

  database_name       = "DEMO_DB"
  data_retention_days = 7
}
```

#### Advanced Example (examples/advanced/)
Show more complex usage with multiple features.

### 4. Update Documentation

#### Update Input/Output Tables
Use `terraform-docs` to auto-generate:
```bash
# Install terraform-docs
brew install terraform-docs

# Generate documentation
terraform-docs markdown table --output-file README.md .
```

Or manually update the tables in README.md.

### 5. Test Your Module

```bash
# Format code
terraform fmt -recursive

# Initialize
terraform init -backend=false

# Validate
terraform validate

# Test examples
cd examples/basic
terraform init
terraform plan
```

### 6. Enable GitHub Actions

The workflow will automatically run when you push to GitHub. It validates:
- ✅ Terraform formatting
- ✅ Terraform initialization
- ✅ Terraform validation
- ✅ Example configurations

The status badge in README.md will show the validation status.

## 📝 Best Practices

### Module Design

1. **Single Responsibility**: Each module should do one thing well
2. **Composability**: Modules should work well together
3. **Sensible Defaults**: Provide good defaults for optional variables
4. **Validation**: Add validation rules to variables
5. **Documentation**: Document all inputs, outputs, and behavior

### Variable Design

```hcl
variable "name" {
  description = "Clear description of what this variable does"
  type        = string
  default     = "sensible-default"  # Optional

  validation {
    condition     = length(var.name) > 0
    error_message = "Name must not be empty."
  }
}
```

### Output Design

```hcl
output "id" {
  description = "Clear description of what this output provides"
  value       = resource.this.id
  sensitive   = false  # Set to true for sensitive data
}
```

### Resource Naming

```hcl
# Good: Use "this" for single resources
resource "snowflake_database" "this" {
  name = var.database_name
}

# Good: Use descriptive names for multiple resources
resource "snowflake_schema" "public" {
  name     = "PUBLIC"
  database = snowflake_database.this.name
}

resource "snowflake_schema" "staging" {
  name     = "STAGING"
  database = snowflake_database.this.name
}
```

## 🧪 Testing

### Manual Testing

```bash
cd examples/basic
terraform init
terraform plan
terraform apply
terraform destroy
```

### Automated Testing with Terratest

See `tests/README.md` for detailed testing instructions.

## 🔄 Continuous Integration

The included GitHub Actions workflow automatically:
1. Checks formatting
2. Validates Terraform configuration
3. Tests example configurations
4. Runs on every push and PR

## 📦 Publishing Your Module

### Terraform Registry

To publish to the Terraform Registry:
1. Tag your releases: `git tag v1.0.0`
2. Push tags: `git push --tags`
3. Follow [Terraform Registry publishing guide](https://www.terraform.io/registry/modules/publish)

### Internal Registry

For internal use:
- Reference via Git: `source = "git::https://github.com/org/module.git"`
- Use specific versions: `source = "git::https://github.com/org/module.git?ref=v1.0.0"`

## 🎨 Customization Tips

### For Snowflake Modules

Common patterns for Snowflake modules:
- Database management
- Schema management
- Role and grant management
- Warehouse configuration
- Integration setup (storage, external functions, etc.)

### For Multi-Cloud Modules

If your module spans multiple providers:
```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
  snowflake = {
    source  = "Snowflake-Labs/snowflake"
    version = "~> 0.94"
  }
}
```

## 🆘 Troubleshooting

### Pre-commit Hooks Failing

If optional tools aren't installed:
1. Comment out the failing hooks in `.pre-commit-config.yaml`
2. Or install the tools: `terraform-docs`, `tflint`, `trivy`

### Validation Failing

```bash
# Check formatting
terraform fmt -check -recursive

# Check validation
terraform init -backend=false
terraform validate
```

### GitHub Actions Failing

Check the workflow run in GitHub Actions tab for detailed error messages.

## 📚 Additional Resources

- [Terraform Module Best Practices](https://www.terraform.io/docs/language/modules/develop/index.html)
- [Snowflake Provider Documentation](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs)
- [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- [Terratest Documentation](https://terratest.gruntwork.io/)

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to modules created from this template.

## 📄 License

This template is licensed under Apache 2.0. See [LICENSE](LICENSE) for details.

---

**Questions?** Open an issue in the template repository or your module's repository.
