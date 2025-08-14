terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "project"
  region = var.aws_region
}

# ======================
# Security Groups (Módulo existente)
# ======================
module "security_groups" {
  source = "./modules/cloudops-ref-repo-aws-sg-terraform"

  providers = {
    aws.project = aws.project
  }

  vpc_id = var.vpc_id
  tags   = var.common_tags
}

# ======================
# ALB privado (Módulo existente)
# ======================
module "alb" {
  source    = "./modules/cloudops-ref-repo-aws-elb-terraform" # tu módulo existente
  providers = {
    aws.project = aws.project
  }

  lb_config = {
    ecs_alb = {
      internal                         = true
      subnets                          = var.private_subnets
      security_groups                  = [module.security_groups.alb_sg_id]
      load_balancer_type               = "application"
      idle_timeout                     = 60
      drop_invalid_header_fields       = true
      enable_deletion_protection       = false
      waf_arn                          = null
      application_id                   = "ecs-alb"
      additional_tags                  = var.common_tags

      target_groups = {
        ecs_service = {
          port                = 80
          protocol            = "HTTP"
          vpc_id              = var.vpc_id
          target_type         = "ip"
          healthy_threshold   = 2
          unhealthy_threshold = 2
          interval            = 30
          matcher             = "200-399"
          path                = "/"
          additional_tags     = var.common_tags
        }
      }

      listeners = {
        http = {
          port               = 80
          protocol           = "HTTP"
          default_target_group_id = "ecs_service"
        }
      }
    }
  }

  depends_on = [module.security_groups]
}

# ======================
# VPC Link (Módulo propio)
# ======================
module "vpc_link" {
  source = "./modules/vpc_link"

  providers = {
    aws.project = aws.project
  }

  name           = "${var.project}-vpc-link"
  target_alb_arn = module.alb.load_balancer_info["ecs_alb"].alb_arn
  tags           = var.common_tags
  depends_on = [module.alb]
}


# ======================
# API Gateway (módulo existente)
# ======================
module "api_gateway" {
  source = "./modules/cloudops-ref-repo-aws-api-terraform"
  
  providers = {
    aws.project = aws.project
  }

  aws_region        = var.aws_region
  environment       = var.environment
  common_tags       = var.common_tags

  client            = var.client
  project           = var.project
  application       = var.application
  functionality     = var.functionality

  lambda_name       = var.lambda_name
  stage_name        = var.stage_name
  api_template      = var.api_template
  api_template_vars = var.api_template_vars
  endpoint_type     = var.endpoint_type
  
  # Este valor lo obtendremos del módulo vpc_link
  private_api_vpce  = module.vpc_link.vpc_link_id
  depends_on = [module.vpc_link]
}

# ======================
# ECS Cluster (módulo existente)
# ======================
module "ecs_cluster" {
  source = "./modules/cloudops-ref-repo-aws-ecs-cluster-terraform"

  cluster_config = {
    myapp = {
      containerInsights      = "enabled"
      enableCapacityProviders = true
      additional_tags = {
        Environment = "dev"
        Owner       = "team-backend"
      }
    }
  }

  providers = {
    aws.project = aws
  }
}

# ======================
# ECR (módulo existente)
# ======================
module "ecr" {
  source     = "./modules/cloudops-ref-repo-aws-ecr-terraform"
  providers = {
    aws.project = aws.project
  }

  client      = var.client
  project     = var.project
  environment = var.environment
  application = var.application

  ecr_config = {
    app1 = {
      functionality         = "backend"
      force_delete          = true
      image_tag_mutability  = "MUTABLE"

      encryption_configuration = [
        {
          encryption_type = "AES256"
          kms_key         = null
        }
      ]

      image_scanning_configuration = [
        {
          scan_on_push = true
        }
      ]

      lifecycle_rules = [
        {
          rulePriority = 1
          description  = "Eliminar imágenes antiguas"
          selection = {
            tagStatus   = "untagged"
            countType   = "sinceImagePushed"
            countUnit   = "days"
            countNumber = 30
          }
          action = {
            type = "expire"
          }
        }
      ]

      access_type       = "private"
      additional_tags   = {}
    }
  }
}

