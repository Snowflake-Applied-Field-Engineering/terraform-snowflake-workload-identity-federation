# Tests

This directory contains automated tests for the Terraform module.

## Test Frameworks

### Terratest (Go)

[Terratest](https://terratest.gruntwork.io/) is a Go library that provides patterns and helper functions for testing infrastructure code.

#### Setup

1. Install Go (>= 1.21)
2. Initialize Go module:
   ```bash
   go mod init github.com/Snowflake-Applied-Field-Engineering/terraform-module-template/tests
   go get github.com/gruntwork-io/terratest/modules/terraform
   go get github.com/stretchr/testify/assert
   ```

#### Example Test

Create `basic_test.go`:

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestBasicExample(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../examples/basic",
        Vars: map[string]interface{}{
            "name": "test-resource",
            "environment": "test",
        },
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Validate outputs
    output := terraform.Output(t, terraformOptions, "id")
    assert.NotEmpty(t, output)
}
```

#### Running Tests

```bash
cd tests
go test -v -timeout 30m
```

### Terraform Test (Native)

Terraform 1.6+ includes native testing capabilities.

Create `main.tftest.hcl`:

```hcl
run "basic_validation" {
  command = plan

  assert {
    condition     = length(var.name) > 0
    error_message = "Name must not be empty"
  }
}

run "apply_and_verify" {
  command = apply

  assert {
    condition     = output.id != ""
    error_message = "Resource ID should not be empty"
  }
}
```

Run with:
```bash
terraform test
```

## Test Structure

```
tests/
├── README.md              # This file
├── basic_test.go          # Basic functionality tests
├── advanced_test.go       # Advanced feature tests
├── integration_test.go    # Integration tests
├── go.mod                 # Go module definition
└── go.sum                 # Go module checksums
```

## Best Practices

1. **Parallel Testing**: Run tests in parallel when possible
2. **Cleanup**: Always destroy resources after tests
3. **Isolation**: Each test should be independent
4. **Timeouts**: Set appropriate timeouts for long-running tests
5. **Retries**: Implement retry logic for flaky operations
6. **Cost Management**: Be mindful of cloud costs during testing

## CI/CD Integration

Tests can be integrated into GitHub Actions:

```yaml
- name: Run Tests
  run: |
    cd tests
    go test -v -timeout 30m
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Resources

- [Terratest Documentation](https://terratest.gruntwork.io/)
- [Terraform Testing Guide](https://www.terraform.io/docs/language/modules/testing-experiment.html)
- [Testing Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/part3.html)
