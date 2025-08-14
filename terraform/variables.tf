###########################################
# Variables Generales del Proyecto
###########################################
variable "client" {
  description = "Nombre del cliente"
  type        = string
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, qa, prod)"
  type        = string
}

variable "application" {
  description = "Nombre de la aplicación"
  type        = string
}

###########################################
# Configuración de Providers
###########################################
variable "aws_region" {
  description = "Región principal de AWS para el proyecto"
  type        = string
  default     = "us-east-1"
}

variable "prod_region" {
  description = "Región de AWS para entorno prod (opcional)"
  type        = string
  default     = "us-east-1"
}

variable "prod_profile" {
  description = "Perfil AWS CLI para otra cuenta (opcional)"
  type        = string
  default     = ""
}

###########################################
# Configuración ECR
###########################################
variable "ecr_config" {
  description = "Configuración de repositorios ECR"
  type = list(object({
    functionality              = string
    force_delete                = bool
    image_tag_mutability        = string
    access_type                 = string
    encryption_configuration    = list(object({
      encryption_type = string
      kms_key         = optional(string)
    }))
    image_scanning_configuration = list(object({
      scan_on_push = bool
    }))
    lifecycle_rules = list(object({
      rulePriority = number
      description  = string
      selection    = object({
        tagStatus   = string
        countType   = string
        countUnit   = optional(string)
        countNumber = number
      })
      action = object({
        type = string
      })
    }))
  }))
}

###########################################
# Configuración ECS
###########################################
variable "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  type        = string
}

variable "ecs_task_definition" {
  description = "Definición de la tarea ECS"
  type = object({
    family                   = string
    network_mode              = string
    cpu                       = string
    memory                    = string
    requires_compatibilities  = list(string)
    execution_role_arn        = string
    task_role_arn             = string
    container_definitions     = string
  })
}

variable "ecs_service_config" {
  description = "Configuración del servicio ECS"
  type = object({
    desired_count          = number
    launch_type            = string
    subnets                = list(string)
    security_groups        = list(string)
    assign_public_ip       = bool
    deployment_minimum_healthy_percent = number
    deployment_maximum_percent        = number
    health_check_grace_period_seconds = number
  })
}

###########################################
# Configuración CloudWatch Logs
###########################################
variable "cloudwatch_log_group_name" {
  description = "Nombre del grupo de logs en CloudWatch"
  type        = string
}

variable "cloudwatch_retention_in_days" {
  description = "Días de retención de logs en CloudWatch"
  type        = number
  default     = 30
}

###########################################
# IAM
###########################################
variable "iam_roles" {
  description = "Mapa de roles IAM para el servicio"
  type = map(object({
    assume_role_policy = string
    tags               = map(string)
  }))
}
