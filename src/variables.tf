locals {
  project_tag = "ScoutSuite"
  ss_tags = {
    "ss:project"   = local.project_tag
    "ss:managedBy" = "Tofu"
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "ec2_instance_type" {
  description = "EC2 instance type. AWS Free Tier types are t2.micro or t3.micro"
  type        = string
  default     = "t3a.medium"
}
