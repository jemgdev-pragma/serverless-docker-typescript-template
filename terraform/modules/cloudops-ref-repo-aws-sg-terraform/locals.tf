###########################################
########## Local Variables ###############
###########################################

locals {
  # Generar nombres estandarizados para los security groups
  sg_names = {
    for k, v in var.sg_config : k => "${var.client}-${var.project}-${var.environment}-sg-${v.service}-${v.application}"
  }
  
  # Filtrar reglas de ingress para facilitar su procesamiento
  ingress_rules = {
    for idx, rule in flatten([
      for sg_key, sg in var.sg_config : [
        for i, ingress in sg.ingress : {
          sg_key = sg_key
          rule   = ingress
          idx    = "${sg_key}_ingress_${i}"
        }
      ]
    ]) : rule.idx => rule
  }
  
  # Filtrar reglas de egress para facilitar su procesamiento
  egress_rules = {
    for idx, rule in flatten([
      for sg_key, sg in var.sg_config : [
        for i, egress in sg.egress : {
          sg_key = sg_key
          rule   = egress
          idx    = "${sg_key}_egress_${i}"
        }
      ]
    ]) : rule.idx => rule
  }
}
