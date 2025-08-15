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
  client      = var.client
  project     = var.project
  environment = var.environment

  sg_config = {
    "elb" = {
      service     = "alb"
      application = "tutorias"
      description = "Security group for alb tutorias"
      vpc_id      = data.aws_vpc.vpc.id
      additional_tags = {
        application-tier = "backend"
      }

      ingress = [
        {
          from_port       = 8080
          to_port         = 8080
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          prefix_list_ids = []
          self            = false
          description     = "Allow HTTP inbound"
        }
      ]

      egress = [
        {
          from_port       = 0
          to_port         = 0
          protocol        = "-1"
          cidr_blocks     = ["0.0.0.0/0"]
          prefix_list_ids = []
          security_groups = []
          self            = false
          description     = "Allow all outbound traffic"
        }
      ]
    },
    "ecs" = {
      service     = "ecs"
      application = "tutorias"
      description = "Security group for ecs tutorias"
      vpc_id      = data.aws_vpc.vpc.id
      additional_tags = {
        application-tier = "tutorias"
      }

      ingress = [
        {
          from_port       = 8080
          to_port         = 8080
          protocol        = "tcp"
          cidr_blocks     = []
          security_groups = ["elb"]
          prefix_list_ids = []
          self            = false
          description     = "Allow traffic on port 7008 from ALB delivery"
        },
        {
          from_port       = 8080
          to_port         = 8080
          protocol        = "tcp"
          cidr_blocks     = []
          security_groups = []
          prefix_list_ids = []
          self            = true
          description     = "Allow traffic on port 7008 from the same security group delivery"
        }
      ]

      egress = [
        {
          from_port       = 0
          to_port         = 0
          protocol        = "-1"
          cidr_blocks     = ["0.0.0.0/0"]
          prefix_list_ids = []
          security_groups = []
          self            = false
          description     = "Allow all outbound traffic"
        }
      ]
    }
    "rds" = {
      service     = "rds"
      application = "mysql"
      description = "Security group for Aurora Mysql"
      vpc_id      = data.aws_vpc.vpc.id
      additional_tags = {
        application-tier = "database"
      }

      ingress = [
        {
          from_port       = 3306
          to_port         = 3306
          protocol        = "tcp"
          cidr_blocks     = []
          security_groups = ["ecs"]
          prefix_list_ids = []
          self            = false
          description     = "Allow Mysql traffic from ECS security group"
        }
      ]

      egress = [
        {
          from_port       = 0
          to_port         = 0
          protocol        = "-1"
          cidr_blocks     = ["0.0.0.0/0"]
          prefix_list_ids = []
          security_groups = []
          self            = false
          description     = "Allow all outbound traffic"
        }
      ]
    }
  }
}

# ======================
# ALB privado (Módulo existente)
# ======================
module "alb" {
  source    = "./modules/cloudops-ref-repo-aws-elb-terraform"

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
  source = "./modules/vpc-link-terraform"

  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
  }

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

  providers = {
    aws.project = aws.project
  }

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

# ======================
# CloudWatch Log Group para ECS (Módulo propio)
# ======================
resource "aws_cloudwatch_log_group" "ecs_mi_app" {
  providers = {
    aws.project = aws.project
  }
  name              = "/ecs/${var.client}-${var.project}-${var.environment}-${var.application}"
  retention_in_days = 30
  skip_destroy      = false

  tags = {
    Name        = "${var.client}-${var.project}-${var.environment}-${var.application}-logs"
    Environment = var.environment
    Project     = var.project
    Client      = var.client
  }

  lifecycle {
    prevent_destroy = false
  }
}

# ======================
# IAM Roles para ECS (Módulo existente)
# ======================
module "iam_roles_ecs" {
  source = "./modules/cloudops-ref-repo-aws-iam-terraform"
  providers = {
    aws.project = aws.project
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  iam_config = [
    # Execution Role
    {
      functionality        = "ecs-exec"
      application          = "mi-app"
      service              = "ecs"
      path                 = "/"
      type                 = "Service"
      identifiers          = ["ecs-tasks.amazonaws.com"]
      principal_conditions = []
      managed_policy_arns  = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
      policies = []
    },

    # Task Role
    {
      functionality        = "ecs-task"
      application          = "mi-app"
      service              = "ecs"
      path                 = "/"
      type                 = "Service"
      identifiers          = ["ecs-tasks.amazonaws.com"]
      principal_conditions = []
      managed_policy_arns  = []
      policies = [
        {
          policy_description = "Permitir enviar logs a CloudWatch"
          policy_statements = [
            {
              sid       = "CloudWatchLogsAccess"
              actions   = [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
              ]
              resources = ["*"]
              effect    = "Allow"
              condition = []
            }
          ]
        }
      ]
    }
  ]

  depends_on = [
    module.ecs_cluster,
    module.ecr,
    module.alb,
    module.iam_roles_ecs,
    aws_cloudwatch_log_group.ecs_mi_app
  ]
}

# ======================
# ECS Service + Task (módulo existente)
# ======================
module "ecs_service_mi_app" {
  source = "./modules/cloudops-ref-repo-aws-ecs-service-terraform"

  providers = {
    aws.project = aws.project
  }

  client       = var.client
  project      = var.project
  environment  = var.environment
  application  = var.application

  ecs_config = {
    cpu                 = "256"
    memory              = "512"
    execution_role_arn = module.iam_roles_ecs.iam_roles_info["ecs-exec-mi-app-ecs"].role_arn
    task_role_arn      = module.iam_roles_ecs.iam_roles_info["ecs-task-mi-app-ecs"].role_arn

    # ECR repositorio creado por el módulo ECR
    ecr_functionality   = "app1"
    image_tag           = "latest"

    container_port      = 3000

    # CloudWatch Logs (puedes declararlo antes como recurso o módulo)
    log_group           = aws_cloudwatch_log_group.ecs_mi_app.name

    # ECS Cluster desde módulo
    cluster_arn         = module.ecs_cluster.cluster_arns["myapp"]

    desired_count       = 1
    subnets             = var.private_subnets

    # Security group del ALB o específico para ECS
    security_groups     = [module.security_groups.ecs_sg_id]

    # Target Group desde módulo ALB
    target_group_arn    = module.alb.target_group_arns["ecs_service"]
  }

  depends_on = [
    module.ecs_cluster,
    module.ecr,
    module.alb,
    aws_cloudwatch_log_group.ecs_mi_app
  ]
}