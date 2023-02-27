variable "common" {
  type = object({
    project = string
    env = string
  })
}

variable "secret_name" {
  type        = string
  description = "name of secret"
}