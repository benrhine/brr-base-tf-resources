
# locals {
#   selected_region = data.aws_region.current.name == "us-west-2" ? "us-east-2" : data.aws_region.current.name
# }
#
# # # Allows for region to be passed in from calling module OR defaults to current execution environment retrieved in data.tf
# variable "aws_region" {
#   description = "AWS region"
#   type        = string
#   default     = local.selected_region
# }
#
# # Allows for region to be passed in from calling module OR defaults to current execution environment retrieved in data.tf
# variable "aws_account" {
#   description = "AWS Account"
#   type        = string
# }

# Values Overridden by TFVARS ==================================================
## Terraform

## Git
variable "github_token" {
  description = "GitHub PAT with repo and actions permissions (optional if using env var)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_org_name" {
  description = "Name of git org"
  type        = string
  default     = "benrhine"
}

variable "git_repo_name" {
  description = "Name of git repo"
  type        = string
  default     = "brr-base-tf-resources"
}

variable "git_env_name" {
  description = "Name of git environment"
  type        = string
  default     = ""
}

variable "current_account" {
  description = "Which account is currently selected"
  type        = string
  default     = ""
}

variable "current_env" {
  description = "Which environment is currently selected"
  type        = string
  default     = "dev"
}

variable "git_role_duration" {
  description = "Duration that role is available"
  type        = number
  default     = 900
}

variable "git_aws_region" {
  description = "Aws Region for GitHub to authenticate into"
  type        = string
  default     = "us-east-2"
}

# Terraform: ===================================================================
variable "framework_prefix" {
  description = "What IaC tool is being used for this deployment?"
  type        = string
  default     = "tf"
}

# Business: ====================================================================
variable "business_area_name" {
  description = "Business area - Rhine Consulting"
  type        = string
  default     = "rc"
}

variable "team_name" {
  description = "Name of the team - Ben Rhine"
  type        = string
  default     = "BRR"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "account_resources"
}

# variable "deployment_bucket_name" {
#   description = "Name of the S3 bucket to create that will hold deployment artifacts"
#   type        = string
#   default     = "tf-${var.aws_region.current.name}-cross-account-shared-services"
# }

variable "account_tools" {
  description = "Aws account number"
  type        = string
  default     = "792981815698"
}

variable "account_non_prod" {
  description = "Aws account number"
  type        = string
  default     = "998530368070"
}

variable "account_prod" {
  description = "Aws account number"
  type        = string
  default     = "NOT-DEFINED"
}

variable "tag_environment_tools" {
  description = "Name of environment"
  type        = string
  default     = "BRR-TOOLS"
}

variable "iam_role_name" {
  description = "Name of the role being created"
  type        = string
  default     = "github_oidc_ci_assume_role"
}

variable "tag_environment" {
  description = "Name of environment"
  type        = string
  default     = ""
}

variable "tag_environment_non_prod" {
  description = "Name of environment"
  type        = string
  default     = "BRR-NP"
}

variable "tag_environment_prod" {
  description = "Name of environment"
  type        = string
  default     = "BRR-PROD"
}

variable "tag_name" {
  description = "Resource name"
  type        = string
  default     = ""
}

variable "tag_origination_repo" {
  description = "Name of the repository that contains the code that controls this resource"
  type        = string
  default     = "resource-templates"
}

variable "ssm_objects_to_create" {
  type = list(object({
    name            = string
    description     = string
    type            = string  # This value is defaulted in ssm module variables
    data_type       = string  # This value is defaulted in ssm module variables
    value           = string
    tag_environment = string
  }))
  default = [
    {
      name            = "tf.brr.tools.build.s3.bucket.name"
      description     = "Deployment bucket created by account-resources"
      type            = "String"  # This value is defaulted
      data_type       = "text"    # This value is defaulted
      value           = "test" #module.s3.aws_s3_bucket.bucket
      tag_environment = "BRR-TOOLS"
    }
  ]
}

variable "cloudwatch_queries_to_create" {
  type = list(object({
    name            = string
    value           = string

  }))

  validation {
    condition = alltrue([for x in var.cloudwatch_queries_to_create : can(regex("^(general-.)", x.name))])
    error_message = "Property name must start with 'general'."
  }

  default = [
    {
      name            = "general-find-all-debug"
      value           = "DEBUG"
    },
    {
      name            = "general-find-all-info"
      value           = "INFO"
    },
    {
      name            = "general-find-all-warnings"
      value           = "WARNING"
    },
    {
      name            = "general-find-all-errors"
      value           = "ERROR"
    },
    {
      name            = "general-find-all-aws-xray"
      value           = "AWS_XRAY"
    },
    # Note the following values are double quoted in CloudFormation/Serverless but only support single quotes here
    # not sure if that matters when running the query
    {
      name            = "general-find-all-json-debug"
      value           = "fields @timestamp, @message, @logStream, @log | filter level = 'WARN' | sort @timestamp desc | limit 20"
    },
    {
      name            = "general-find-all-json-info"
      value           = "fields @timestamp, @message, @logStream, @log | filter level = 'INFO' | sort @timestamp desc | limit 20"
    },
    {
      name            = "general-find-all-json-warnings"
      value           = "fields @timestamp, @message, @logStream, @log | filter level = 'WARN' | sort @timestamp desc | limit 20"
    },
    {
      name            = "general-find-all-json-errors"
      value           = "fields @timestamp, @message, @logStream, @log | filter level = 'ERROR' | sort @timestamp desc | limit 20"
    },
    {
      name            = "general-find-all-json-cold-start-true"
      value           = "fields @timestamp, @message, @logStream, @log | filter coldStart = 'true' | sort @timestamp desc | limit 20"
    },
    {
      name            = "general-find-all-json-cold-start-false"
      value           = "fields @timestamp, @message, @logStream, @log | filter coldStart = 'false' | sort @timestamp desc | limit 20"
    },
  ]
}

variable "iam_objects_to_create" {
  type = list(object({
    iam_role_name           = string
    iam_role_description    = string  # This value is defaulted in ssm module variables
    iam_role_path           = string  # This value is defaulted in ssm module variables
    iam_assume_role_policy  = string
    iam_tags_environment    = string
  }))
  default = [
    {
      iam_role_name           = "tf-base-assumed-service-role"
      iam_role_description    = "This is the base role that will be assumed"
      iam_role_path           = "/"
      iam_assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "AWS": "arn:aws:iam::792981815698:root"
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
EOF
      iam_tags_environment    = "tools"
    },
    {
      iam_role_name           = "tf-base-ervice-role"
      iam_role_description    = "This is the base role that will be used to deploy resources"
      iam_role_path           = "/"
      iam_assume_role_policy  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "codepipeline.amazonaws.com",
                    "codebuild.amazonaws.com",
                    "cloudformation.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
      iam_tags_environment    = "tools"
    },
    {
      iam_role_name           = "tf-account-resources-resource-deploy-service-role"
      iam_role_description    = "This is the base role that will be assumed"
      iam_role_path           = "/service-role/"
      iam_assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "Service": [
                  "codebuild.amazonaws.com"
              ]
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
EOF
      iam_tags_environment    = "tools"
    },
    {
      iam_role_name           = "account-resources-codepipeline-role"
      iam_role_description    = "This is the base role that will be assumed"
      iam_role_path           = "/service-role/"
      iam_assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "Service": [
                  "codepipeline.amazonaws.com"
              ]
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
EOF
      iam_tags_environment    = "tools"
    },
    {
      iam_role_name           = "tf-codepipeline-event-rule-role"
      iam_role_description    = "This role allows for the CodePipeline to execute"
      iam_role_path           = "/"
      iam_assume_role_policy  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "events.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
      iam_tags_environment    = "tools"
    },
  ]
}

# variable "iam_policies_and_attachments_to_create" {
#   type = list(object({
#     iam_policy_name           = string
#     iam_policy_description    = string
#     iam_policy                = string
#     iam_policy_role_to_attach = string
#   }))
#   default = [
#     {
#       iam_policy_name           = "tf_account_resources_iam"
#       iam_policy_description    = "Custom IAM policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_iam.json
#       iam_policy_role_to_attach = module.base_assumed_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_iam_all"
#       iam_policy_description    = "Custom IAM policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_iam_all.json
#       iam_policy_role_to_attach = module.base_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_codebuild_resource_simple"
#       iam_policy_description    = "Custom CodeBuild policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_codebuild_resource_simple.json
#       iam_policy_role_to_attach = module.base_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_codepipeline"
#       iam_policy_description    = "Custom CodePipeline policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_codepipeline.json
#       iam_policy_role_to_attach = module.base_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_ssm"
#       iam_policy_description    = "Custom SSM policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_ssm.json
#       iam_policy_role_to_attach = module.base_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_assume_role_1"
#       iam_policy_description    = "Custom assume policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_assume_role.json
#       iam_policy_role_to_attach = module.base_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_log"
#       iam_policy_description    = "Custom IAM policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_log.json
#       iam_policy_role_to_attach = module.codebuild_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_log_group_build"
#       iam_policy_description    = "Custom CodeBuild policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_log_group_build.json
#       iam_policy_role_to_attach = module.codebuild_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_s3_resource_policy"
#       iam_policy_description    = "Custom CodePipeline policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_s3_resource_policy.json
#       iam_policy_role_to_attach = module.codebuild_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_codecommit_resource_repo_policy"
#       iam_policy_description    = "Custom CodeCommit policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_codecommit_resource_repo_policy.json
#       iam_policy_role_to_attach = module.codebuild_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_codebuild_resource_policy"
#       iam_policy_description    = "Custom assume policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_codebuild_resource_policy.json
#       iam_policy_role_to_attach = module.base_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_codepipeline_simple"
#       iam_policy_description    = "Custom IAM policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_codepipeline_simple.json
#       iam_policy_role_to_attach = module.codebuild_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_iam_pass_through"
#       iam_policy_description    = "Custom CodeBuild policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_iam_pass_through.json
#       iam_policy_role_to_attach = module.codebuild_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_ssm_get"
#       iam_policy_description    = "Custom SSM GET policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_ssm_get.json
#       iam_policy_role_to_attach = module.codebuild_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_assume_role_2"
#       iam_policy_description    = "Custom assume policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_assume_role.json
#       iam_policy_role_to_attach = module.codebuild_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_everything"
#       iam_policy_description    = "Custom everything policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_everything.json
#       iam_policy_role_to_attach = module.codepipeline_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_s3_restricted"
#       iam_policy_description    = "Custom assume policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_s3_restricted.json
#       iam_policy_role_to_attach = module.codepipeline_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_account_resources_assume_role_3"
#       iam_policy_description    = "Custom assume policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_account_resources_assume_role.json
#       iam_policy_role_to_attach = module.codepipeline_service_role.created_role.name
#     },
#     {
#       iam_policy_name           = "tf_domain_resources_pipeline_execution_policy"
#       iam_policy_description    = "Custom assume policy for base role"
#       iam_policy                = data.aws_iam_policy_document.tf_domain_resources_pipeline_execution_policy.json
#       iam_policy_role_to_attach = module.codepipeline_event_rule_role.created_role.name
#     }
#   ]
# }