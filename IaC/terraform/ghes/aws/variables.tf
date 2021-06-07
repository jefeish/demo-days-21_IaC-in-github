variable stack_name {
  description = "Stack name prefix"
  type        = string
  default     = "jefeish"
}

variable region {
  type = string
  default = "us-west-1"
} 

variable instance_type {
  type = string
  default = "c5.4xlarge"
}

variable ghes_version {
  type = string
  default = "2.22.7"
}

variable vpc_id {
  type = string
  default = "vpc-315cef56"   # us-west-1
}