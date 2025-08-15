locals {
  variables = merge(var.api_template_vars, { 
    api_name = "${var.project}-${var.client}-${var.environment}-api-${var.application}-${var.functionality}",
    aws_region = var.aws_region
    account_id = data.aws_caller_identity.current.account_id 
    lambda_function_name  = "${var.client}-${var.project}-${var.environment}-${var.lambda_name}"
  })

  base64_api_template = split("base64,", var.api_template)[1]
}