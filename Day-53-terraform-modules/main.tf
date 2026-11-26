terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

module "report_file" {
  source      = "./modules/text_file"
  environment = "dev"
  filename    = "${path.module}/report-dev.txt"
  content     = "Created by reusable module for Development."
}

module "summary_file" {
  source      = "./modules/text_file"
  environment = "prod"
  filename    = "${path.module}/summary-prod.txt"
  content     = "Created by the same reusable module for Production."
}
