terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      # Declaramos que este módulo puede recibir un alias
      configuration_aliases = [aws.project]
    }
  }
}