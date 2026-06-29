variable "aws_region" {
  description = "AWS region where the POC is deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources."
  type        = string
  default     = "pci-devops-poc"
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "poc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "allowed_ingress_cidrs" {
  description = "Finite list of CIDR ranges allowed to reach the public ALB."
  type        = list(string)
  default     = ["203.0.113.10/32"]
}

variable "domain_name" {
  description = "DNS name for the application. Terraform creates and validates an ACM certificate for this name."
  type        = string

  validation {
    condition     = length(var.domain_name) > 0 && can(regex("^[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.domain_name))
    error_message = "domain_name must be a valid DNS name, for example app.example.com."
  }
}

variable "hosted_zone_name" {
  description = "Optional Route53 hosted zone name. If empty, Terraform derives the parent zone from domain_name, for example example.com from app.example.com."
  type        = string
  default     = ""
}

variable "instance_type_app" {
  description = "EC2 instance type for the app server."
  type        = string
  default     = "t3.micro"
}

variable "instance_type_db" {
  description = "EC2 instance type for the MySQL server."
  type        = string
  default     = "t3.micro"
}

variable "egress_allowed_domains" {
  description = "Domain suffixes allowed by AWS Network Firewall for outbound HTTPS traffic."
  type        = list(string)
  default = [
    ".example.com",
    "example.com",
    ".secureweb.com",
    "secureweb.com",
    ".amazonaws.com",
    ".amazonlinux.com",
  ]
}
