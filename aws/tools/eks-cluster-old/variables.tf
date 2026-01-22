
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
  default     = "eks-cluster"
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
  default     = "brr-base-tf-resources"
}
