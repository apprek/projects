# ./variables.tf

variable "provisioning_role_arn" {
  type        = string
  description = "Assume this role when provisioning resources"
}

variable "tags" {
  type = map
}

variable "remediation_role_name" {
  type    = string
  default = "CloudCustodian-Remediations"
}

variable "allow_terminations" {
  type    = bool
  default = false
}

variable "operations_account" {
  type    = string
  default = "{central_management_account}"
}

variable aws_region {
  type        = set(string)
  default     = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
    "ca-central-1", 
    "eu-central-1", 
    "eu-west-1", 
    "eu-west-2", 
    "eu-west-3", 
    "eu-north-1", 
    "ap-south-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "ap-northeast-1",
    "sa-east-1" 
  ]
  description = "List of mulpile AWS Regions"
}
