terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ======================
# Proveedor principal AWS (sin alias)
# ======================
provider "aws" {
  region = var.aws_region
}

# ======================
# Proveedor AWS con alias "project" para todos los módulos
# ======================
provider "aws" {
  alias  = "project"
  region = var.aws_region
}

# ======================
# Proveedor opcional para otro entorno (ej: prod)
# ======================
provider "aws" {
  alias   = "prod"
  region  = var.prod_region          # variable opcional para prod
  profile = var.prod_profile         # variable opcional para prod
}
