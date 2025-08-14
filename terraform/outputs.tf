output "ecs_cluster_info" {
  description = "Información de los clusters ECS creados"
  value = {
    for name, cluster in aws_ecs_cluster.cluster : name => {
      id   = cluster.id
      name = cluster.name
      arn  = cluster.arn
    }
  }
}

output "alb_arn" {
  value       = module.alb.load_balancer_info["ecs_alb"].alb_arn
  description = "ARN del Application Load Balancer privado"
}

output "alb_dns_name" {
  value       = module.alb.load_balancer_info["ecs_alb"].dns_name
  description = "DNS interno del ALB privado"
}

output "vpc_link_id" {
  value       = module.vpc_link.vpc_link_id
  description = "ID del VPC Link usado por API Gateway"
}

output "api_gateway_id" {
  value       = module.api_gateway.api_id
  description = "ID del API Gateway"
}

output "api_gateway_invoke_url" {
  value       = module.api_gateway.invoke_url
  description = "URL de invocación del API Gateway"
}

output "ecs_cluster_arn" {
  value       = module.ecs_cluster.cluster_arns["myapp"]
  description = "ARN del ECS Cluster"
}

output "ecs_service_name" {
  value       = module.ecs_service_mi_app.ecs_service_name
  description = "Nombre del ECS Service"
}

output "ecs_task_role_arn" {
  value       = module.iam_roles_ecs.iam_roles_info["ecs-task-mi-app-ecs"].role_arn
  description = "ARN del ECS Task Role"
}

output "ecs_execution_role_arn" {
  value       = module.iam_roles_ecs.iam_roles_info["ecs-exec-mi-app-ecs"].role_arn
  description = "ARN del ECS Execution Role"
}

output "ecr_repository_url" {
  value       = module.ecr.ecr_repositories["app1"].repository_url
  description = "URL del repositorio ECR para la imagen de la aplicación"
}

output "ecs_log_group_name" {
  value       = aws_cloudwatch_log_group.ecs_mi_app.name
  description = "Nombre del log group de CloudWatch para ECS"
}
