output "sg_info" {
  description = "Información de los grupos de seguridad creados, incluyendo ID y nombre"
  value = { for k, sg in aws_security_group.sg : k => { id = sg.id, name = sg.name } }
}

output "sg_ids" {
  description = "Mapa de IDs de los grupos de seguridad creados, indexados por clave"
  value = { for k, sg in aws_security_group.sg : k => sg.id }
}

output "sg_names" {
  description = "Mapa de nombres de los grupos de seguridad creados, indexados por clave"
  value = { for k, sg in aws_security_group.sg : k => sg.name }
}

output "sg_arns" {
  description = "Mapa de ARNs de los grupos de seguridad creados, indexados por clave"
  value = { for k, sg in aws_security_group.sg : k => sg.arn }
}
