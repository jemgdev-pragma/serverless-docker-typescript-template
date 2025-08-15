resource "aws_api_gateway_vpc_link" "this" {
  name        = var.name
  target_arns = [var.target_alb_arn]
  tags        = var.tags
}
