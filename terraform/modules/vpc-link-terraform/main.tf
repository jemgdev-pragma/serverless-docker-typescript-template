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

resource "aws_api_gateway_vpc_link" "this" {
  name        = var.name
  target_arns = [var.target_alb_arn]
  tags        = var.tags
}
