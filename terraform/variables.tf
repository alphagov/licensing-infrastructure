variable "environment_type" {
  type        = string
  description = "The type of environment (development, staging or production)"
}

variable "availability_zones" {
  type        = list(string)
  description = "A list of availability zones in which to deploy multi-AZ infrastructure. All zones must be in the region set in the AWS provider"

  validation {
    condition     = length(var.availability_zones) >= 1 && length(var.availability_zones) <= 9
    error_message = "Must set between 1 and 9 availability zones"
  }
}
