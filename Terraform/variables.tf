

variable provisioning_role_arn {  
  type = string
  description = "Assume this role when provisioning resources"
}

variable tags {
  type = map
}

variable aws_iam_role {
  type = string
  default = ""
}