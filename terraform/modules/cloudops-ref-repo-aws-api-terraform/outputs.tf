output "rest_api_id" {
  description = "ID del API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "invoke_url" {
  description = "URL para invocar el API Gateway (incluye el stage)"
  value       = aws_api_gateway_stage.stage.invoke_url
}