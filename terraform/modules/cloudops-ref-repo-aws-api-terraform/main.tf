# Crea el API Gateway con el tipo de endpoint seleccionado
resource "aws_api_gateway_rest_api" "this" {
  provider    = aws.project
  name        = "${var.project}-${var.client}-${var.environment}-api-${var.application}-${var.functionality}"
  description = "API Gateway"
  body        = data.template_file.api_template.rendered

  endpoint_configuration {
    types            = [upper(var.endpoint_type)]
    vpc_endpoint_ids = upper(var.endpoint_type) == "PRIVATE" ? [var.private_api_vpce] : null
  }
}

# Despliega el API Gateway en un stage
resource "aws_api_gateway_deployment" "this" {
  provider    = aws.project
  rest_api_id = aws_api_gateway_rest_api.this.id
  
  triggers = {
    redeployment = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_rest_api.this]
}

resource "aws_api_gateway_stage" "stage" {
  provider      = aws.project
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name

  tags = merge(
    var.common_tags,
    { Name = "${var.project}-${var.client}-${var.environment}-api-${var.application}-${var.functionality}" },
  )
}
