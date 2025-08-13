variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "stage" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "subnet_id" {
  type        = string
}

variable "port" {
  type        = number
}

variable "expose_port" {
  type        = number
}
