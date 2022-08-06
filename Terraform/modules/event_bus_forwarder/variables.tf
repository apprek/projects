# ../modules/event_bus_forwarder/variables.tf

variable provisioning_role_arn {  
  type = string
  description = "Assume this role when provisioning resources"
}

variable aws_iam_role {
  type = string
  default = "data.aws_iam_role.id"
}

variable target_account {
  type        = string
  default     = "{central_management_account}"
  description = "The central account that will handle forwarded events"
}

variable target_event_bus {
  type        = string
  default     = "default"
  description = "The event bus in the target account that will receive forwarded events"
}

variable tags {
  type = map
}

variable forwarding_role_name {
  type        = string
  default     = "CloudCustodian-EventForwarder"
  description = "Forward CloudTrail events for centralized processing by Cloud Custodian"
}

variable rule_name {
  type        = string
  default     = "custodian-eventbus-forwarder"
  description = "EventBridge rule that will forward events"
}




