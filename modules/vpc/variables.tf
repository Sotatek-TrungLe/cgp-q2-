variable "common" {
  type = object({
    project = string
    env = string
  })
}

variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
}

variable "subnet_az" {
  type = map(number)
  description = "Map of AZ to a number that should be used for subnets"
}

variable "enable_nat_gw" {
  description = "If set to true, it will create nat gw"
  type = bool
}