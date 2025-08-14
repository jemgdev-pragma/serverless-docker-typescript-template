variable "name" {
  type        = string
  description = "Nombre del VPC Link"
}

variable "target_alb_arn" {
  type        = string
  description = "ARN del ALB privado"
}

variable "tags" {
  type        = map(string)
  default     = {}
}