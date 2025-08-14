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