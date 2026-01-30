
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
  default     = 3600
}

variable "git_aws_region" {
  description = "Aws Region for GitHub to authenticate into"
  type        = string
  default     = "us-west-2"
}

variable "aws_region" {
  description = "Aws Region"
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
  default     = "001-setup-s3-bucket"
}

variable "project_id" {
  description = "Id of the project"
  type        = string
  default     = "001"
}

# This value should be same as the S3 bucket postfix and should be used for all project that use the given S3 bucket
# for maintaining their state
variable "project_postfix" {
  description = "Randomly generated value generated when creating initial S3 bucket"
  type        = string
  default     = "vfqysx7t"
}

variable "environment" {
  description = "What environment is this deployed in"
  type        = string
  default     = "dev"
}

variable "environment_prefix" {
  description = "Prefix resource names with environment?"
  type        = bool
  default     = false
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

variable "iam_role_name_2" {
  description = "Name of the role being created"
  type        = string
  default     = "admin_assume_role"
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
    type            = string # This value is defaulted in ssm module variables
    data_type       = string # This value is defaulted in ssm module variables
    value           = string
    tag_environment = string
  }))
  default = [
    {
      name            = "tf.brr.tools.build.s3.bucket.name"
      description     = "Deployment bucket created by account-resources"
      type            = "String" # This value is defaulted
      data_type       = "text"   # This value is defaulted
      value           = "test"   #module.s3.aws_s3_bucket.bucket
      tag_environment = "BRR-TOOLS"
    }
  ]
}
