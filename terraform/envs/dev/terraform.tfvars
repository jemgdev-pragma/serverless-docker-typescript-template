###########################################
# Variables Generales del Proyecto
###########################################
client      = "somos-pragma"
project     = "serverless-docker-typescript-template"
application = "serverless-docker-typescript-template-api"

###########################################
# Entorno activo (dev/prod)
###########################################
environment = "dev"

###########################################
# Configuración Providers
###########################################
aws_region   = "us-east-1"   # para dev
prod_region  = "us-east-1"   # para prod, puedes cambiar región si quieres
prod_profile = ""            # perfil opcional AWS CLI para prod

###########################################
# Configuración ECR
###########################################
ecr_config = [
  {
    functionality            = "payment-api"
    force_delete             = true
    image_tag_mutability     = "MUTABLE"
    access_type              = "private"
    encryption_configuration = [
      {
        encryption_type = "AES256"
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
        description  = "Mantener solo las últimas 10 imágenes"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
]

###########################################
# Configuración ECS
###########################################
ecs_cluster_name = "serverless-docker-typescript-template-ecs-cluster-${environment}"

data "aws_caller_identity" "current" {}

ecs_task_definition = {
  family                   = "serverless-docker-typescript-template-task"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/myAppTaskRole"
  container_definitions    = <<DEFINITION
[
  {
    "name": "payment-container",
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${aws_region}.amazonaws.com/payment-api:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/payment-service-${environment}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

ecs_service_config = {
  desired_count                     = 2
  launch_type                       = "FARGATE"
  subnets                           = ["subnet-abc123", "subnet-def456"]
  security_groups                   = ["sg-0123456789abcdef0"]
  assign_public_ip                  = true
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent        = 200
  health_check_grace_period_seconds = 60
}

###########################################
# Configuración CloudWatch Logs
###########################################
cloudwatch_log_group_name    = "/ecs/payment-service-${environment}"
cloudwatch_retention_in_days = 30

###########################################
# IAM
###########################################
iam_roles = {
  paymentServiceTaskRole = {
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
    tags = {
      Environment = "${environment}"
      Project     = "payment-service"
    }
  }
}
