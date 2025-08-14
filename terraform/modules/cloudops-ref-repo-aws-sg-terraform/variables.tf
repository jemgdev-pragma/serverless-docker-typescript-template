###########################################
########## Common variables ###############
###########################################

variable "environment" {
  type        = string
  description = "Environment where resources will be deployed"
  
  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn, prod."
  }
}

variable "client" {
  type        = string
  description = "Client name"
}

variable "project" {
  type        = string
  description = "Project name"
}

###########################################
####### Security Group variables ##########
###########################################
variable "sg_config" {
  description = "Configuración de Security Groups"
  type = map(object({
    description     = string                      # Descripción del grupo de seguridad
    vpc_id          = string                      # ID de la VPC donde se creará el grupo de seguridad
    service         = string                      # Servicio asociado (ej: alb, ecs, rds)
    application     = string                      # Nombre de la aplicación
    additional_tags = optional(map(string), {})   # Etiquetas específicas para este grupo de seguridad
    ingress         = list(object({
      from_port       = number                    # Puerto de inicio para el rango
      to_port         = number                    # Puerto final para el rango
      protocol        = string                    # Protocolo (tcp, udp, icmp, -1 para todos)
      cidr_blocks     = list(string)              # Lista de bloques CIDR permitidos
      security_groups = list(string)              # Lista de grupos de seguridad permitidos
      prefix_list_ids = list(string)              # Lista de IDs de prefijos permitidos
      self            = bool                      # Si el propio grupo de seguridad se permite
      description     = string                    # Descripción de la regla
    }))
    egress          = list(object({
      from_port       = number                    # Puerto de inicio para el rango
      to_port         = number                    # Puerto final para el rango
      protocol        = string                    # Protocolo (tcp, udp, icmp, -1 para todos)
      cidr_blocks     = list(string)              # Lista de bloques CIDR permitidos
      prefix_list_ids = list(string)              # Lista de IDs de prefijos permitidos
      security_groups = list(string)              # Lista de grupos de seguridad permitidos
      self            = bool                      # Si el propio grupo de seguridad se permite
      description     = string                    # Descripción de la regla
    }))
  }))
  
  validation {
    condition = alltrue([
      for sg_key in keys(var.sg_config) : !startswith(sg_key, "sg-")
    ])
    error_message = "Las claves en sg_config no deben comenzar con 'sg-' para evitar confusiones con los IDs de security groups de AWS."
  }
  
  validation {
    condition = alltrue([
      for sg_key, sg in var.sg_config : 
      contains(["-1", "tcp", "udp", "icmp", "icmpv6"], lower(sg.ingress[0].protocol))
    ])
    error_message = "El protocolo debe ser uno de: '-1', 'tcp', 'udp', 'icmp', 'icmpv6'."
  }
}
