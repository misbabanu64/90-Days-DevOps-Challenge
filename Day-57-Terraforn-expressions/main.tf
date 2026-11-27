terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "environments" {
  type = map(string)
  default = {
    dev     = "Updated Development environment"
    prod    = "Production environment"
    staging = "Staging environment"
  }
}

resource "local_file" "environment" {
  for_each = var.environments
  filename = "${path.module}/${each.key}.txt"
  content  = "${upper(each.key)}: ${each.value}"
}
