terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "environment" {
  filename = "${path.module}/${terraform.workspace}.txt"
  content  = "Workspace: ${terraform.workspace} | Message: ${var.env_message}"
}
