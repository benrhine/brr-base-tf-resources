
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

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ci_vpc"
}

variable "project_id" {
  description = "Name of the project"
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