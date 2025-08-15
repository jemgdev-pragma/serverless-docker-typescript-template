variable "common_tags" {
  type = map(string)
}

variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "client" {
  type = string
}

variable "project" {
  type = string  
}

variable "application" {
  type = string  
}

variable "functionality" {
  type = string  
}

variable "lambda_name" {
  type = string  
}

variable "stage_name" {
  type = string  
}

variable "api_template" {
  description = "path of API template swagger file"
}

variable "api_template_vars" {
  description = "parameters for swagger file template"
}

variable "endpoint_type" {
  description = "Tipo de endpoint del API Gateway: PRIVATE, REGIONAL o EDGE"
  type        = string
  default     = "REGIONAL"
}

variable "private_api_vpce" {
  description = "ID del VPC Endpoint autorizado para acceder a la API privada"
  type        = string
  # Debes asignar un valor si usas endpoint_type = "PRIVATE"
}