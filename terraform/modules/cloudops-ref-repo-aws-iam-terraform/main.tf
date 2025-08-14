###########################################
########### IAM Resources #################
###########################################

resource "aws_iam_role" "iam_role" {
  provider = aws.project
  for_each = { for item in var.iam_config :
    "${item.functionality}-${item.application}-${item.service}" => {
      "index" : index(var.iam_config, item)
      "functionality" : item.functionality
      "application" : item.application
      "service": item.service
      "path" : item.path
    }
  }
  name               = join("-", tolist([var.client, var.project, var.environment, "role", each.value["service"], each.value["application"], each.value["functionality"]]))
  path               = each.value["path"]
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
  tags = merge({ Name = "${join("-", tolist([var.client, var.project, var.environment, "role", each.value["service"], each.value["application"], each.value["functionality"]]))}" },
  {application_id = each.value["application"]})
}

data "aws_iam_policy_document" "assume_role" {
  provider = aws.project  
  for_each = { for item in var.iam_config :
    "${item.functionality}-${item.application}-${item.service}" => {
      "index" : index(var.iam_config, item)
      "type" : item.type
      "identifiers" : item.identifiers
      "principal_conditions" : item.principal_conditions
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = each.value["type"]
      identifiers = each.value["identifiers"]
    }

    dynamic "condition" {
      for_each = each.value["principal_conditions"]
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

data "aws_iam_policy_document" "dynamic_policy" {
  provider = aws.project
  for_each = { for item in flatten([for iam in var.iam_config : [for policy in iam.policies : {
    "role_index" : index(var.iam_config, iam)
    "policy_index" : index(iam.policies, policy)
    "functionality" : iam.functionality
    "service": iam.service
    "application" : iam.application
    "description" : policy.policy_description
    "policy_statements" : policy.policy_statements
    }]]) :
    "${item.functionality}-${item.application}-${item.service}" => item if length(item.policy_statements) > 0
  }
  dynamic "statement" {
    for_each = each.value["policy_statements"]
    content {
      sid       = statement.value["sid"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
      effect    = statement.value["effect"]

      dynamic "condition" {
        for_each = statement.value["condition"]
        content {
          test     = condition.value["test"]
          variable = condition.value["variable"]
          values   = condition.value["values"]
        }
      }
    }
  }
}

resource "aws_iam_policy" "policy" {
  provider = aws.project
  for_each = { for item in flatten([for iam in var.iam_config : [for policy in iam.policies : {
    "role_index" : index(var.iam_config, iam)
    "policy_index" : index(iam.policies, policy)
    "functionality" : iam.functionality
    "application" : iam.application
    "service": iam.service
    "description" : policy.policy_description
    "policy_statements" : policy.policy_statements
    }]]) :
    "${item.functionality}-${item.application}-${item.service}" => item if length(item.policy_statements) > 0
  }
  name        = join("-", tolist([var.client, var.project, var.environment, "policy", each.value["service"], each.value["application"], each.value["functionality"]]))
  description = each.value["description"]
  policy      = data.aws_iam_policy_document.dynamic_policy[each.key].json
  tags = merge({ Name = "${join("-", tolist([var.client, var.project, var.environment, "policy", each.value["service"], each.value["application"], each.value["functionality"]]))}" })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  provider = aws.project
  for_each = { for item in flatten([for iam in var.iam_config : [for policy in iam.policies : {
    "role_index" : index(var.iam_config, iam)
    "policy_index" : index(iam.policies, policy)
    "functionality" : iam.functionality
    "application" : iam.application
    "service": iam.service
    "description" : policy.policy_description
    "policy_statements" : policy.policy_statements
    }]]) :
    "${item.functionality}-${item.application}-${item.service}" => item if length(item.policy_statements) > 0
  }
  role       = aws_iam_role.iam_role["${each.value.functionality}-${each.value.application}-${each.value.service}"].name
  policy_arn = aws_iam_policy.policy[each.key].arn
}

# Atachar Politicas Administradas AWS
resource "aws_iam_role_policy_attachment" "managed_policy_attachment" {
  provider = aws.project
  for_each = { for item in flatten([
    for iam in var.iam_config : [
      for arn in iam.managed_policy_arns : {
        role_name = "${iam.functionality}-${iam.application}-${iam.service}"
        policy_arn = arn
      }
    ]
  ]) : "${item.role_name}-${item.policy_arn}" => item }

  role       = aws_iam_role.iam_role[each.value.role_name].name
  policy_arn = each.value.policy_arn
}