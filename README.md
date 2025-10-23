This module creates all the Snowflake resources required for WIF.

TODO proper readme <!-- TODO proper readme -->
TODO tfdocs <!-- TODO tfdocs -->

<!-- # Terraform Module Template

[![Terraform Validation](https://github.com/Snowflake-Applied-Field-Engineering/terraform-module-template/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/Snowflake-Applied-Field-Engineering/terraform-module-template/actions/workflows/terraform-validate.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A template repository for creating Terraform modules, with a focus on Snowflake resources. This template provides a standardized structure and best practices for building reusable, well-documented Terraform modules.

## Features

- 🏗️ **Standardized Structure**: Organized file layout following Terraform best practices
- ✅ **Automated Validation**: GitHub Actions workflow for continuous validation
- 📚 **Documentation Templates**: Pre-configured README and examples
- 🔒 **Security**: Pre-commit hooks and security scanning setup
- 🧪 **Testing Ready**: Structure for Terratest or other testing frameworks
- 📦 **Modular Design**: Easy to customize for AWS, Azure, GCP, or Snowflake resources

## Quick Start

### Using This Template

1. **Create a new repository from this template**
   - Click "Use this template" button on GitHub
   - Or clone and customize:
   ```bash
   git clone https://github.com/Snowflake-Applied-Field-Engineering/terraform-module-template.git my-new-module
   cd my-new-module
   rm -rf .git
   git init
   ```

2. **Customize for your module**
   - Update `README.md` with your module's purpose
   - Modify `variables.tf` with your required inputs
   - Update `main.tf` with your resource definitions
   - Configure `outputs.tf` with useful outputs
   - Update `examples/` with realistic use cases

3. **Initialize and validate**
   ```bash
   terraform init
   terraform fmt -recursive
   terraform validate
   ```

## Module Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform-validate.yml    # CI/CD validation workflow
├── examples/
│   ├── basic/                        # Basic usage example
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── advanced/                     # Advanced usage example
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── tests/                            # Test files (Terratest, etc.)
│   └── README.md
├── main.tf                           # Main resource definitions
├── variables.tf                      # Input variable declarations
├── outputs.tf                        # Output value declarations
├── versions.tf                       # Terraform and provider version constraints
├── locals.tf                         # Local values (optional)
├── data.tf                           # Data source definitions (optional)
├── README.md                         # Module documentation
├── LICENSE                           # License file
└── .gitignore                        # Git ignore patterns
```

## Usage

### Basic Example

```hcl
module "example" {
  source = "github.com/Snowflake-Applied-Field-Engineering/terraform-module-template"

  # Required variables
  name   = "my-resource"
  region = "us-east-1"

  # Optional variables
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### Advanced Example

See the [examples/advanced](./examples/advanced/) directory for more complex usage scenarios.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | ~> 5.0 |
| snowflake | ~> 0.94 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |
| snowflake | ~> 0.94 |

## Resources

List the resources created by this module:

| Name | Type |
|------|------|
| [resource_type.name](link-to-docs) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the resource | `string` | n/a | yes |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the created resource |
| arn | The ARN of the created resource |

## Development

### Prerequisites

- Terraform >= 1.5.0
- Pre-commit (optional, for git hooks)
- Go >= 1.21 (if using Terratest)

### Local Development

1. **Format code**
   ```bash
   terraform fmt -recursive
   ```

2. **Validate configuration**
   ```bash
   terraform init -backend=false
   terraform validate
   ```

3. **Run examples**
   ```bash
   cd examples/basic
   terraform init
   terraform plan
   ```

### Testing

```bash
cd tests
go test -v -timeout 30m
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

- Follow [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- Run `terraform fmt` before committing
- Ensure all validation checks pass
- Update documentation for any changes

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For questions, issues, or contributions, please:
- Open an issue on GitHub
- Contact the Snowflake Applied Field Engineering team

## Acknowledgments

- Snowflake Applied Field Engineering Team
- Terraform Community

---

**Note**: This is a template repository. Replace this content with your module's specific documentation. -->
