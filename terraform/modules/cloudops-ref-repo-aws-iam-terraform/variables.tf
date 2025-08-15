###########################################
########## Common variables ###############
###########################################

variable "environment" {
  type = string
  description = "Environment where resources will be deployed"
}

variable "client" {
  type = string
  description = "Client name"
}

variable "project" {
  type = string  
  description = "Project name"
}

###########################################
############# IAM variables ###############
###########################################

variable "iam_config" {
  type = list(object({
    functionality = string
    application   = string
    service       = string
    path          = string
    type          = string
    identifiers   = list(string)
    principal_conditions = list(object({
          test     = string
          variable = string
          values   = list(string)
    }))
    policies = list(object({
      policy_description = string
      policy_statements = list(object({
        sid       = string
        actions   = list(string)
        resources = list(string)
        effect    = string
        condition = list(object({
          test     = string
          variable = string
          values   = list(string)
        }))
      }))
    }))
    managed_policy_arns = optional(list(string), [])
  }))
  description = <<EOF
    - application: (string) Application name.
    - functionality: (string) Functionality name.
    - service: (string) Service name. 
    - path: (string) Path to the role.
    - type: (string) Type of principal. Valid values include AWS, Service, Federated, CanonicalUser and *.
    - identifiers: (list(string)) List of identifiers for principals. When type is AWS, these are IAM principal ARNs, e.g., arn:aws:iam::12345678901:role/yak-role. When type is Service, these are AWS Service roles, e.g., lambda.amazonaws.com. When type is Federated, these are web identity users or SAML provider ARNs, e.g., accounts.google.com or arn:aws:iam::12345678901:saml-provider/yak-saml-provider.
    - principal_conditions: (list(object))
        - test: (string) Name of the IAM condition operator to evaluate.
        - values: (string) Values to evaluate the condition against. If multiple values are provided, the condition matches if at least one of them applies. That is, AWS evaluates multiple values as though using an "OR" boolean operation.
        - variable: (string) Name of a Context Variable to apply the condition to. Context variables may either be standard AWS variables starting with aws: or service-specific variables prefixed with the service name.
    - policies (list(object))
      - policy_description: (string) Policy description.
      - policy_statements: (list(object))
        - sid: (string) Sid (statement ID) is an identifier for a policy statement.
        - actions: (list(string)) List of actions that this statement either allows or denies
        - resources: (list(string)) List of resource ARNs that this statement applies to. This is required by AWS if used for an IAM policy. Conflicts with not_resources.
        - effect: (string) Whether this statement allows or denies the given actions. Valid values are Allow and Deny. Defaults to Allow.
        - condition:
          - test: (string) Name of the IAM condition operator to evaluate.
          - variable: (string) Name of a Context Variable to apply the condition to. Context variables may either be standard AWS variables starting with aws: or service-specific variables prefixed with the service name.
          - values: (list(string)) Values to evaluate the condition against. If multiple values are provided, the condition matches if at least one of them applies. That is, AWS evaluates multiple values as though using an "OR" boolean operation.
    - managed_policy_arns: (optional(list(string))) List of AWS managed policy ARNs to attach to the IAM role. For example: ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]. Defaults to an empty list if not specified.
  EOF
}