
# Business: ====================================================================
variable "org_name_abv" {
  description = "Organization name - abbreviation"
  type        = string
  default     = "rc"
}

variable "org_name_full" {
  description = "Organization name - full"
  type        = string
  default     = "Rhine Consulting"
}

variable "team_name" {
  description = "Name of the team - Ben Rhine"
  type        = string
  default     = "BRR"
}

variable "aws_region" {
  description = "Aws Region"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "test"
}

variable "project_id" {
  description = "Id of the project"
  type        = string
  default     = "001"
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

variable "environment_instance_type" {
  description = "What instance type backs the environment"
  type        = string
  default     = "t3.medium"
}

variable "cluster_auth_mode" {
  description = "What type of auth is Kubernetes configured with"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "cluster_ng_desired_size" {
  description = "How many instances are desired?"
  type        = number
  default     = 1
}

variable "cluster_ng_max_size" {
  description = "What is the maximum number of instances"
  type        = number
  default     = 2
}

variable "cluster_ng_min_size" {
  description = "What is the minimum number of instances"
  type        = number
  default     = 1
}

variable "cluster_ng_max_unavailable" {
  description = "What is the maximum number unavailable"
  type        = number
  default     = 1
}

variable "cluster_ng_remote_access_key" {
  description = "Which ssh key to use"
  type        = string
  default     = "brr-test"
}

# This value should be same as the S3 bucket postfix and should be used for all project that use the given S3 bucket
# for maintaining their state
variable "project_postfix" {
  description = "Randomly generated value generated when creating initial S3 bucket"
  type        = string
  default     = "vfqysx7t"
}

variable "requires_cluster_admin_role_001" {
  description = "Personal SSO role - easy interaction with Kubernetes"
  type        = string
  default     = "AWSReservedSSO_AdministratorAccess_eeb8e63974797d2b"
}

variable "requires_cluster_admin_role_002" {
  description = "CI execution role - may be necessary to use the same role as was used for creation"
  type        = string
  default     = "github_oidc_ci_assume_role_vfqysx7t"
}