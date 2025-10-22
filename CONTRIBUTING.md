# Contributing to Terraform Module Template

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and collaborative environment.

## How to Contribute

### Reporting Issues

1. Check if the issue already exists in the [Issues](https://github.com/Snowflake-Applied-Field-Engineering/terraform-module-template/issues) section
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (if applicable)
   - Expected vs actual behavior
   - Terraform version and provider versions
   - Relevant code snippets or error messages

### Submitting Changes

1. **Fork the repository**
   ```bash
   git clone https://github.com/Snowflake-Applied-Field-Engineering/terraform-module-template.git
   cd terraform-module-template
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the coding standards below
   - Add or update tests as needed
   - Update documentation

4. **Test your changes**
   ```bash
   terraform fmt -recursive
   terraform init -backend=false
   terraform validate
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `style:` Code style changes (formatting, etc.)
   - `refactor:` Code refactoring
   - `test:` Adding or updating tests
   - `chore:` Maintenance tasks

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template
   - Link any related issues

## Coding Standards

### Terraform Style Guide

Follow the [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html):

1. **Formatting**
   - Use 2 spaces for indentation
   - Run `terraform fmt` before committing
   - Maximum line length: 120 characters

2. **Naming Conventions**
   - Use lowercase with underscores: `my_variable_name`
   - Be descriptive: `database_name` not `db_name`
   - Avoid abbreviations unless widely understood

3. **Resource Naming**
   - Use singular nouns: `resource "aws_s3_bucket" "this"`
   - Use `this` for single resources
   - Use descriptive names for multiple resources

4. **Variables**
   - Always include description
   - Specify type constraints
   - Provide sensible defaults where appropriate
   - Add validation rules when needed

5. **Outputs**
   - Always include description
   - Mark sensitive outputs appropriately
   - Group related outputs

### Documentation

1. **README.md**
   - Keep the main README up to date
   - Include usage examples
   - Document all inputs and outputs
   - Add requirements and dependencies

2. **Code Comments**
   - Comment complex logic
   - Explain "why" not "what"
   - Keep comments up to date

3. **Examples**
   - Provide working examples
   - Include both basic and advanced usage
   - Document prerequisites

## Testing

### Manual Testing

1. **Format Check**
   ```bash
   terraform fmt -check -recursive
   ```

2. **Validation**
   ```bash
   terraform init -backend=false
   terraform validate
   ```

3. **Plan**
   ```bash
   cd examples/basic
   terraform init
   terraform plan
   ```

### Automated Testing

If adding tests:
- Use Terratest or Terraform's native testing
- Ensure tests are idempotent
- Clean up resources after tests
- Document test requirements

## Pull Request Process

1. **PR Checklist**
   - [ ] Code follows style guidelines
   - [ ] Tests pass locally
   - [ ] Documentation updated
   - [ ] Examples updated (if needed)
   - [ ] CHANGELOG updated (if applicable)
   - [ ] No merge conflicts

2. **Review Process**
   - At least one approval required
   - CI/CD checks must pass
   - Address review comments
   - Squash commits if requested

3. **Merging**
   - Maintainers will merge approved PRs
   - Use "Squash and merge" for clean history

## Development Setup

### Prerequisites

- Terraform >= 1.5.0
- Git
- Text editor or IDE
- (Optional) Pre-commit hooks

### Setting Up Pre-commit Hooks

```bash
pip install pre-commit
pre-commit install
```

This will automatically run checks before each commit.

### IDE Setup

#### VS Code
Install extensions:
- HashiCorp Terraform
- Terraform doc snippets

#### IntelliJ/PyCharm
Install plugins:
- Terraform and HCL

## Release Process

Releases are managed by maintainers:

1. Update version in relevant files
2. Update CHANGELOG.md
3. Create and push a tag
4. GitHub Actions will create the release

## Questions?

- Open an issue for questions
- Tag maintainers if urgent
- Check existing documentation first

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

---

Thank you for contributing! 🎉
