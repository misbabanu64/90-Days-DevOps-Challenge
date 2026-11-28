# Day 58: Terraform Validation & Testing (Configuration Quality & Safe Infrastructure Changes)

## Objective
Validate Terraform configurations, enforce input variable validation rules, understand `precondition` and `postcondition` lifecycle assertions, explore automated testing with `terraform test`, and compare static analysis/security scanning tools (TFLint, Checkov, and Trivy). This lab uses local files only—incurring zero AWS resource usage or cloud charges.

---

## 1. Lab Configuration Files

### `main.tf`
```hcl
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Use dev, test, or prod."
  }
}

resource "local_file" "report" {
  filename = "${path.module}/${var.environment}.txt"
  content  = "Validation passed for ${var.environment}."
}
```

### `terraform.tfvars`
```hcl
environment = "dev"
```

---

## 2. Validation Exercises & Command Outputs

### Step 1: Formatting, Initialization, and Validation
Commands executed:
```bash
terraform fmt -check
terraform fmt -recursive
terraform init
terraform validate
```

**Output:**
```text
Success! The configuration is valid.
```

![Terraform fmt, init, and validate output](./01-fmt-validate.png)

---

### Step 2: Execution Plan with Valid Input (`environment = "dev"`)
Command executed:
```bash
terraform plan
```

**Output:**
```text
Terraform will perform the following actions:

  # local_file.report will be created
  + resource "local_file" "report" {
      + content              = "Validation passed for dev."
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./dev.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

![Terraform plan with valid dev input](./02-terraform-plan-dev.png)

---

### Step 3: Testing Custom Variable Validation (`environment = "stage"`)
Updated `terraform.tfvars` to `environment = "stage"` and ran `terraform plan`.

**Output (Custom Validation Error):**
```text
│ Error: Invalid value for variable
│
│   on terraform.tfvars line 1:
│    1: environment = "stage"
│     ├────────────────
│     │ var.environment is "stage"
│
│ Use dev, test, or prod.
│
│ This was checked by the validation rule at main.tf:13,3-13.
```

![Invalid input validation error](./03-invalid-input-error.png)

---

### Step 4: Restoring Valid Input, Applying, and Verifying Output
Restored `environment = "dev"` in `terraform.tfvars` and ran:
```bash
terraform plan
terraform apply -auto-approve
cat dev.txt
```

**Output:**
```text
local_file.report: Creating...
local_file.report: Creation complete after 0s [id=...]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

$ cat dev.txt
Validation passed for dev.
```

![Corrected apply and dev.txt verification](./04-corrected-apply-verify.png)

---

### Step 5: Cleanup
Cleaned up local resources using:
```bash
terraform destroy -auto-approve
```

**Output:**
```text
local_file.report: Destroying... [id=...]
local_file.report: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

---

### Why `terraform validate` Does Not Replace `terraform plan`
* `terraform validate` only checks local HCL syntax, attribute types, and internal configuration consistency without inspecting state files or external provider APIs.
* `terraform plan` compares the desired configuration against the real-world state and cloud/provider APIs to calculate exact resource creations, updates, or destructions, catching runtime/provider-level issues that `validate` cannot detect.

---

## 3. Preconditions vs. Postconditions

Both `precondition` and `postcondition` are configured inside a resource or data source's `lifecycle` block to enforce custom assertions:

| Feature | Precondition | Postcondition |
| :--- | :--- | :--- |
| **Execution Timing** | Evaluated **before** Terraform creates, updates, or reads a resource (often during `plan`). | Evaluated **after** Terraform creates, updates, or reads a resource (during `apply`). |
| **Primary Purpose** | Validates assumptions and input conditions before making changes. | Verifies the final state and attributes of the provisioned resource. |
| **Can Reference `self`?** | **No** (the resource has not been created/updated yet). | **Yes** (`self.<attribute>` can inspect resulting values). |

### Reference Example (Not Executed)
```hcl
# Reference Example: Precondition and Postcondition
resource "local_file" "config_report" {
  filename = "${path.module}/${var.environment}-config.txt"
  content  = "Environment: ${var.environment}"

  lifecycle {
    # Precondition: Ensures direct local report generation is blocked for prod
    precondition {
      condition     = var.environment != "prod"
      error_message = "Direct local report generation is not allowed in prod."
    }

    # Postcondition: Verifies the generated file content is not empty after creation
    postcondition {
      condition     = length(self.content) > 0
      error_message = "Generated report file must not be empty."
    }
  }
}
```

---

## 4. Terraform Testing (`terraform test` & `.tftest.hcl`)

Terraform provides a native testing framework using test files ending in `.tftest.hcl` executed via the `terraform test` command.

### Key Components
* **`run` blocks:** Define individual test scenarios in sequence. Setting `command = plan` runs tests safely without provisioning billable cloud infrastructure, while `command = apply` tests full resource creation.
* **`assert` blocks:** Evaluate boolean `condition` expressions against planned or created resource attributes and fail the test with a custom `error_message` if false.
* **`expected_failures`:** Allows negative testing by specifying variables, preconditions, postconditions, or check blocks expected to fail. If Terraform blocks the invalid input as expected, the test passes.

### Zero-Cost Test Example (`validation.tftest.hcl`)
```hcl
# Verifies valid input generates the expected file content during plan
run "valid_environment_test" {
  command = plan

  variables {
    environment = "dev"
  }

  assert {
    condition     = local_file.report.content == "Validation passed for dev."
    error_message = "Report content did not match expected dev output."
  }
}

# Verifies invalid input ("stage") triggers the variable validation error
run "invalid_environment_test" {
  command = plan

  variables {
    environment = "stage"
  }

  expected_failures = [
    var.environment
  ]
}
```
**What this test verifies:** The first `run` block confirms that passing `"dev"` produces the expected file content without creating real infrastructure (`command = plan`). The second `run` block uses `expected_failures` to confirm that passing `"stage"` properly triggers the custom validation rule on `var.environment`.

---

## 5. Static Analysis & Security Scanning Tools Comparison

| Tool | Primary Focus | What It Detects |
| :--- | :--- | :--- |
| **TFLint** | Terraform Linting & Best Practices | Provider-specific errors (e.g., invalid AWS instance types), deprecated syntax, unused declarations, and naming convention violations. |
| **Checkov** | IaC Policy & Security Compliance | Security misconfigurations (e.g., unencrypted S3 buckets, open security groups `0.0.0.0/0`, missing logging) mapped to CIS, SOC2, and HIPAA standards. |
| **Trivy (IaC)** | Unified Security & Misconfiguration Scanning | Infrastructure misconfigurations across Terraform, Kubernetes, and Dockerfiles, alongside hardcoded secrets and container/OS vulnerabilities. |

### Why Automated Findings Still Require Human Review
* **Business Context Awareness:** Automated scanners flag broad rules (such as public S3 buckets or open ports) without knowing if a resource is intentionally public (e.g., a static website host or public load balancer).
* **False Positives & Compensating Controls:** Security controls might be enforced outside the scanned module (such as upstream WAFs, SCPs, or private VPC endpoints), requiring engineers to evaluate real risk and apply documented suppressions responsibly.

---

## 6. Interview Questions & Answers

1. **Difference between `terraform fmt` and `terraform validate`?**
   `terraform fmt` checks and rewrites `.tf` files into canonical HCL formatting and style, whereas `terraform validate` checks syntax, attribute types, and internal configuration logic.
2. **Does `terraform validate` guarantee `terraform apply` will succeed?**
   No. `validate` does not inspect state files or query cloud provider APIs, so runtime issues like permission errors, resource name collisions, or quota limits will only surface during `plan` or `apply`.
3. **What is variable validation?**
   A `validation` block inside an `input variable` definition that uses custom `condition` expressions and `error_message` outputs to reject invalid values early during `plan`.
4. **What are preconditions and postconditions?**
   Lifecycle assertions on resources or data sources: `precondition` checks assumptions before an operation runs, while `postcondition` verifies resulting attributes after an operation completes.
5. **What is a `check` block?**
   A top-level continuous validation block introduced in Terraform 1.5+ that runs assertions (often using scoped data sources) and emits non-blocking **warnings** rather than halting `apply` with hard errors.
6. **What is `terraform test` used for?**
   It executes automated unit and integration tests defined in `.tftest.hcl` files to verify resource outputs, variable validations, and infrastructure behavior safely.
7. **What do TFLint and Checkov do?**
   TFLint performs provider-aware linting to catch syntax/provider-specific bugs and enforce code style, while Checkov scans IaC files against security and compliance policies to prevent misconfigurations.

---

## Cost & Safety Note
* Only local files (`dev.txt`) were created and destroyed using `terraform destroy`.
* Zero AWS resources or cloud costs were incurred.
* `.terraform/` and `*.tfstate*` files are excluded via `.gitignore` so no state files or sensitive data are committed to GitHub.
