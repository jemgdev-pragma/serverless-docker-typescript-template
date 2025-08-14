###########################################
####### Security Group Resources ##########
###########################################

resource "aws_security_group" "sg" {
  provider    = aws.project
  for_each    = var.sg_config

  name        = local.sg_names[each.key]
  description = each.value.description
  vpc_id      = each.value.vpc_id

  tags = merge(
    {
      Name = local.sg_names[each.key]
    },
    each.value.additional_tags
  )
}

# Reglas de ingress
resource "aws_security_group_rule" "ingress_rules" {
  provider = aws.project
  for_each = local.ingress_rules

  type              = "ingress"
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  security_group_id = aws_security_group.sg[each.value.sg_key].id
  description       = each.value.rule.description

  # Solo asignar cidr_blocks si self es false y hay valores
  cidr_blocks = each.value.rule.self ? null : (length(each.value.rule.cidr_blocks) > 0 ? each.value.rule.cidr_blocks : null)
  
  # Solo asignar self si es true
  self = each.value.rule.self ? true : null
  
  # Solo asignar prefix_list_ids si hay valores
  prefix_list_ids = length(each.value.rule.prefix_list_ids) > 0 ? each.value.rule.prefix_list_ids : null

  # Manejo seguro de source_security_group_id
  source_security_group_id = (
    length(each.value.rule.security_groups) > 0 && !each.value.rule.self
  ) ? (
    startswith(each.value.rule.security_groups[0], "sg-") 
    ? each.value.rule.security_groups[0]  # Si es un ID directo, usarlo tal cual
    : lookup(aws_security_group.sg, each.value.rule.security_groups[0], null) != null 
      ? aws_security_group.sg[each.value.rule.security_groups[0]].id 
      : null  # Si el SG no existe, devolver null en lugar de fallar
  ) : null
}

# Reglas de egress
resource "aws_security_group_rule" "egress_rules" {
  provider = aws.project
  for_each = local.egress_rules

  type              = "egress"
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  security_group_id = aws_security_group.sg[each.value.sg_key].id
  description       = each.value.rule.description

  # Asegurar que no se pasan listas vacías
  cidr_blocks = length(each.value.rule.cidr_blocks) > 0 ? each.value.rule.cidr_blocks : null
  
  # Solo asignar self si es true
  self = contains(keys(each.value.rule), "self") && each.value.rule.self ? true : null
  
  # Solo asignar prefix_list_ids si hay valores
  prefix_list_ids = length(each.value.rule.prefix_list_ids) > 0 ? each.value.rule.prefix_list_ids : null

  # Manejo seguro de source_security_group_id para egress
  source_security_group_id = (
    contains(keys(each.value.rule), "security_groups") && 
    length(each.value.rule.security_groups) > 0
  ) ? (
    startswith(each.value.rule.security_groups[0], "sg-") 
    ? each.value.rule.security_groups[0]  # Si es un ID directo, usarlo tal cual
    : lookup(aws_security_group.sg, each.value.rule.security_groups[0], null) != null 
      ? aws_security_group.sg[each.value.rule.security_groups[0]].id 
      : null  # Si el SG no existe, devolver null en lugar de fallar
  ) : null
}