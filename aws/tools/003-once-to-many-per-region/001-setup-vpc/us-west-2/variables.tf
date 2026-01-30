
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

########################################################################################################################
# Provider Configuration
########################################################################################################################
variable "aws_region" {
  description = "Aws Region"
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "Local dev profile"
  type        = string
  default     = null
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
  # default     = "xi7egjwf"
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

variable "vpc_cidr_block" {
  description = "Cider block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnet_01" {
  description = "Public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc_public_subnet_02" {
  description = "Public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vpc_private_subnet_01" {
  description = "Private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "vpc_private_subnet_02" {
  description = "Private subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "vpc_public_route_table" {
  description = "Public route table"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_private_route_table" {
  description = "Private route table"
  type        = string
  default     = "0.0.0.0/0"
}

# test comment