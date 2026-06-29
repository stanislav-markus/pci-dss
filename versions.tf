terraform {
  required_version = ">= 1.10.0"

  # Remote state is required for shared GitHub Actions plan/apply runs.
  # Uncomment and configure this backend before enabling CI/CD against a real AWS account.
  #
  # backend "s3" {
  #   bucket       = "CHANGE_ME_TERRAFORM_STATE_BUCKET"
  #   key          = "pci-devops-poc/terraform.tfstate"
  #   region       = "us-east-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
