
########################################################################################################################
# S3 Module Declaration: This module is used to create S3 buckets. In the case of this application this declaration is
# being used to create the default "deployment_bucket" which will contain all generated application artifacts from other
# application deployments.
#
# NOTE: THIS MODULE DOES NOT HAVE ANY DEPENDENCIES!!!
# NOTE2: THIS MODULE SHOULD BE REUSABLE
# WARNING!!! There does not seem to be a way to set the deletion policy in terraform meaning using the destroy command
# WILL DELETE THE BUCKET!!!
########################################################################################################################
# Create a random value to add to the S3 bucket to guarantee uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false # Exclude uppercase characters
  # numeric = false # Exclude numeric characters
}

locals {
  convert_to_underscores = replace(var.git_repo_name, "-", "_")
}

module "s3_tf_state_bucket" {
  source                        = "git::https://github.com/benrhine/brr-s3-module.git?ref=v0.0.1.7"                                          # Where to find the module
  ######################################################################################################################
  #   aws_region                    = data.aws_region.current.name                            # Value retrieved in data.tf
  #   aws_account                   = data.aws_caller_identity.current.account_id             # Value retrieved in data.tf
  #   project_name                  = var.project_name                                        # Value passed in via variables.tf
  # Custom defined value
  create_bucket_name            = "${var.framework_prefix}-state-${random_string.suffix.result}"
  s3_tags_environment           = var.tag_environment_tools                                 # Value passed in via variables.tf
  s3_tags_origination           = var.tag_origination_repo
  s3_tags_project               = var.project_name
}

# Enable versioning on bucket that maintains terraform state
resource "aws_s3_bucket_versioning" "versioning_tf_state" {
  bucket = module.s3_tf_state_bucket.aws_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]
  # GitHub OIDC root CA thumbprint - second value may be unnecessary
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# Create an IAM role to be assumed by GitHub Action
module "github_oidc_ci_assume_role" {
  source = "git::https://github.com/benrhine/brr-iam-roles-module.git?ref=v0.0.1.1" # Where to find the module
  ######################################################################################################################   # Value passed in via variables.tf
  # iam_role_name            = "${var.iam_role_name}_${local.convert_to_underscores}"
  iam_role_name            = "${var.iam_role_name}"
  iam_role_description     = "This is the base CI role that will be assumed"
  iam_assume_role_policy   = data.aws_iam_policy_document.github_oidc_ci_assume_role.json
  iam_tags_environment     = var.tag_environment
  iam_tags_origination     = var.tag_origination_repo
  iam_tags_project         = var.project_name
}

# Attach IAM Policy to newly created role
resource "aws_iam_role_policy_attachment" "github_oidc_ci_assume_role_attachment" {
  role       = module.github_oidc_ci_assume_role.created_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [
    module.github_oidc_ci_assume_role
  ]
}

module "admin_assume_role" {
  source = "git::https://github.com/benrhine/brr-iam-roles-module.git?ref=v0.0.1.1" # Where to find the module
  ######################################################################################################################   # Value passed in via variables.tf
  # iam_role_name            = "${var.iam_role_name}_${local.convert_to_underscores}"
  iam_role_name            = "${var.iam_role_name_2}"
  iam_role_description     = "This is the admin role that will be assumed"
  iam_assume_role_policy   = data.aws_iam_policy_document.admin_assume_role.json
  iam_tags_environment     = var.tag_environment
  iam_tags_origination     = var.tag_origination_repo
  iam_tags_project         = var.project_name
}

# Attach IAM Policy to newly created role
resource "aws_iam_role_policy_attachment" "admin_assume_role_attachment" {
  role       = module.admin_assume_role.created_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [
    module.admin_assume_role
  ]
}

########################################################################################################################
# Store values for CI Actions in GitHub: This is necessary so that the AWS Role can be assumed at execution time
########################################################################################################################
resource "github_actions_secret" "env_secret_1" {
  repository = var.git_repo_name
  # environment     = var.current_env
  secret_name     = "${upper(var.current_env)}_ROLE"
  plaintext_value = module.github_oidc_ci_assume_role.created_role_arn
}

resource "github_actions_secret" "env_secret_2" {
  repository = var.git_repo_name
  # environment     = var.current_env
  secret_name     = "${upper(var.current_env)}_ROLE_DURATION"
  plaintext_value = var.git_role_duration
}

resource "github_actions_secret" "env_secret_3" {
  repository = var.git_repo_name
  # environment     = var.current_env
  secret_name     = "${upper(var.current_env)}_AWS_REGION"
  plaintext_value = var.git_aws_region
}

########################################################################################################################
# Store role for CI Actions in Aws: This is to ensure role is accessible for future actions
########################################################################################################################
module "ci_role_to_assume" {
  source = "git::https://github.com/benrhine/brr-ssm-module.git?ref=v0.0.1.1" # Where to find the module
  ######################################################################################################################
  property_name             = "/${var.business_area_name}/${lower(var.team_name)}/${lower(var.current_env)}/${var.framework_prefix}/${var.iam_role_name}_${local.convert_to_underscores}" # Custom defined value
  property_description      = "Role to assume during CI jobs"                                                                                                               # Custom defined value
  property_value            = module.github_oidc_ci_assume_role.created_role_arn                                                                                            # Value retrieved from module outputs.tf
  property_type             = "SecureString"
  property_tags_environment = var.tag_environment # Value passed in via variables.tf
  property_tags_origination = var.tag_origination_repo
  property_tags_project     = var.project_name
}
