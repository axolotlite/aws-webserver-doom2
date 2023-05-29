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

variable "default_port" {
  description = "the main port for this project"
  type = number
  default = 8000
}