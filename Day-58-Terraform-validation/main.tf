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
