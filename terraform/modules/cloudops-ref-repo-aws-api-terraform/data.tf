data "aws_caller_identity" "current" {
  provider = aws.project
}

data "template_file" "api_template" {
  template = base64decode(local.base64_api_template)
  vars     = local.variables
}