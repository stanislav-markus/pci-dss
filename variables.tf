variable "aws_region" {
  description = "AWS region where the POC is deployed."
  type        = string
  default     = "us-west-2"
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
}

variable "allowed_ingress_cidrs" {
  description = "Finite list of CIDR ranges allowed to reach the public ALB."
  type        = list(string)
  default     = ["203.0.113.10/32"]
}

variable "domain_name" {
  description = "DNS name for the application. Terraform creates and validates an ACM certificate for this name."
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID where DNS records are created."
  type        = string
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
