# **Módulo Terraform: cloudops-ref-repo-aws-iam-terraform**

## Descripción:

Este módulo facilita la creación de los siguientes recursos en AWS:

- IAM Role
- IAM Policy

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo
El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-iam-terraform/
└── sample/iam
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars.sample
    └── variables.tf
├── .gitignore
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.
 
<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2023-09-20 | 3.2.232 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->

## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/iam/providers.tf
provider "aws" {
  alias = "alias01"
  # ... otras configuraciones del provider
}

sample/iam/main.tf
module "iam" {
  source = ""
  providers = {
    aws.project = aws.alias01
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

```hcl
module "iam" {
  source = ""
  
  providers = {
    aws.project = aws.project
  }

  # Common configuration
  client        = "example"
  project       = "example"
  environment   = "dev"
  aws_region    = "us-east-1"
  common_tags = {
      environment   = "dev"
      project-name  = "proyecto01"
      cost-center   = "xxx"
      owner         = "xxx"
      area          = "xxx"
      provisioned   = "xxx"
      datatype      = "xxx"
  }

  # IAM configuration
  iam_config = [
    {
      functionality = "s3"
      application   = "app01"
      service       = "ecs"
      path          = "/service-role/"
      type          = "AWS"
      identifiers   = ["xxxxxxx"]
      principal_conditions = [
        {
          test     = "StringLike"
          variable = "aws:RequestTag/project"
          values   = ["app01"]
        }
      ]
      policies = [
        {
          policy_description = "Policy to allow access to S3 and DynamoDB"
          policy_statements = [
            {
              sid       = "AllowS3Access"
              actions   = ["s3:ListBucket", "s3:GetObject"]
              resources = ["*"]
              effect    = "Allow"
              condition = []
            },
            {
              sid       = "AllowDynamoDBAccess"
              actions   = ["dynamodb:GetItem", "dynamodb:Query", "dynamodb:PutItem"]
              resources = ["*"]
              effect    = "Allow"
              condition = []
            }
          ]
        }
      ]
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.dynamic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | resource |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="application"></a> [application](#input\application) | Application name. | `string` | n/a | yes |
| <a name="functionality"></a> [functionality](#input\functionality) | Functionality name. | `string` | n/a | yes |
| <a name="service"></a> [service](#input\service) | Service name. | `string` | n/a | yes |
| <a name="path"></a> [path](#input\path) | Path to the role. | `string` | n/a | yes |
| <a name="type"></a> [type](#input\type) | Type of principal. Valid values include AWS, Service, Federated, CanonicalUser and *. | `string` | n/a | yes |
| <a name="identifiers"></a> [identifiers](#input\identifiers) | List of identifiers for principals. When type is AWS, these are IAM principal ARNs, e.g., arn:aws:iam::12345678901:role/yak-role. When type is Service, these are AWS Service roles, e.g., lambda.amazonaws.com. When type is Federated, these are web identity users or SAML provider ARNs, e.g., accounts.google.com or arn:aws:iam::12345678901:saml-provider/yak-saml-provider.  | `list(string)` | n/a | yes |
| <a name="principal_conditions.test"></a> [principal_conditions.test](#input\principal_conditions.test) | Name of the IAM condition operator to evaluate. | `string` | n/a | yes |
| <a name="principal_conditions.values"></a> [principal_conditions.values](#input\principal_conditions.values) | Values to evaluate the condition against. If multiple values are provided, the condition matches if at least one of them applies. That is, AWS evaluates multiple values as though using an "OR" boolean operation. | `string` | n/a | yes |
| <a name="principal_conditions.variable"></a> [principal_conditions.variable](#input\principal_conditions.variable) | Name of a Context Variable to apply the condition to. Context variables may either be standard AWS variables starting with aws: or service-specific variables prefixed with the service name. | `string` | n/a | yes |
| <a name="policies.policy_description"></a> [policies.policy_description](#input\policies.policy_description) | Policy description. | `string` | n/a | yes |
| <a name="policies.policy_statements.sid"></a> [policies.policy_statements.sid](#input\policies.policy_statements.sid) | Sid (statement ID) is an identifier for a policy statement. | `string` | n/a | yes |
| <a name="policies.policy_statements.actions"></a> [policies.policy_statements.actions](#input\policies.policy_statements.actions) | List of actions that this statement either allows or denies | `(list(string))` | n/a | yes |
| <a name="policies.policy_statements.resources"></a> [policies.policy_statements.resources](#input\policies.policy_statements.resources) | List of resource ARNs that this statement applies to. This is required by AWS if used for an IAM policy. Conflicts with not_resources. | `(list(string))` | n/a | yes |
| <a name="policies.policy_statements.effect"></a> [policies.policy_statements.effect](#input\policies.policy_statements.effect) | Whether this statement allows or denies the given actions. Valid values are Allow and Deny. Defaults to Allow. | `string` | n/a | yes |
| <a name="policies.policy_statements.condition.test"></a> [policies.policy_statements.condition.test](#input\policies.policy_statements.condition.test) | Name of the IAM condition operator to evaluate. | `string` | n/a | yes |
| <a name="policies.policy_statements.condition.variable"></a> [policies.policy_statements.condition.variable](#input\policies.policy_statements.condition.variable) | Name of a Context Variable to apply the condition to. Context variables may either be standard AWS variables starting with aws: or service-specific variables prefixed with the service name. | `string` | n/a | yes |
| <a name="policies.policy_statements.condition.values"></a> [policies.policy_statements.condition.values](#input\policies.policy_statements.condition.values) | Values to evaluate the condition against. If multiple values are provided, the condition matches if at least one of them applies. That is, AWS evaluates multiple values as though using an "OR" boolean operation. | `(list(string))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_info_repository_url"></a> [ecr_info.repository_url](#output\_ecr_info_repository_url) | URL del repositorio creado |
