terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "demo" {
  content  = "DevOps Winter Arc - Day 54 State Lab"
  filename = "${path.module}/demo.txt"
}
