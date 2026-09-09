variable "environment" {
  type        = string
  description = "The name of this environment. This name should be unique among all environments in use"
}

variable "environment_type" {
  type        = string
  description = "The type of environment (development, staging or production)"
}
