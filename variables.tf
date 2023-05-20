variable "project_name" {
  description = "Name of the project this infrastucture belongs to"
  type        = string
  default     = "tf22"
}

variable "env" {
  description = "Current Environment"
  type        = string
  default     = "dev"
}
