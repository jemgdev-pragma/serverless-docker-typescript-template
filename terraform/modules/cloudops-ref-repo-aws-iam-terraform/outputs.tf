output "iam_roles_info" {
  value = {
    for key, role in aws_iam_role.iam_role : 
    key => {
      "role_arn"  : role.arn,
      "role_name" : role.name,
      "tags"      : role.tags_all,
    }
  }
}