
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

# Create an IAM role to be assumed by GitHub Action
# checkov:skip=CKV_TF_1 "Using pinned module, ignore false positive"
module "github_oidc_ci_assume_role" {
  source = "git::https://github.com/benrhine/brr-iam-roles-module.git?ref=v0.0.1.1" # Where to find the module
  ######################################################################################################################   # Value passed in via variables.tf
  # iam_role_name            = "${var.iam_role_name}_${local.convert_to_underscores}"
  iam_role_name          = "${var.iam_role_name}-${random_string.suffix.result}"
  iam_role_description   = "This is the base CI role that will be assumed"
  iam_assume_role_policy = data.aws_iam_policy_document.github_oidc_ci_assume_role.json
  iam_tags_environment   = var.tag_environment
  iam_tags_origination   = var.tag_origination_repo
  iam_tags_project       = var.project_name
}

# Attach IAM Policy to newly created role
resource "aws_iam_role_policy_attachment" "github_oidc_ci_assume_role_attachment" {
  role       = module.github_oidc_ci_assume_role.created_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [
    module.github_oidc_ci_assume_role
  ]
}

# checkov:skip=CKV_TF_1 "Using pinned module, ignore false positive"
module "admin_assume_role" {
  source = "git::https://github.com/benrhine/brr-iam-roles-module.git?ref=v0.0.1.1" # Where to find the module
  ######################################################################################################################   # Value passed in via variables.tf
  # iam_role_name            = "${var.iam_role_name}_${local.convert_to_underscores}"
  iam_role_name          = "${var.iam_role_name_2}-${random_string.suffix.result}"
  iam_role_description   = "This is the admin role that will be assumed"
  iam_assume_role_policy = data.aws_iam_policy_document.admin_assume_role.json
  iam_tags_environment   = var.tag_environment
  iam_tags_origination   = var.tag_origination_repo
  iam_tags_project       = var.project_name
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
# Store role for CI Actions in Aws: This is to ensure role is accessible for future actions
########################################################################################################################
# checkov:skip=CKV_TF_1 "Using pinned module, ignore false positive"
# module "ci_role_to_assume" {
#   source = "git::https://github.com/benrhine/brr-ssm-module.git?ref=v0.0.1.1" # Where to find the module
#   ######################################################################################################################
#   property_name             = "/${var.business_area_name}/${lower(var.team_name)}/${lower(var.current_env)}/${var.framework_prefix}/${var.iam_role_name}_${local.convert_to_underscores}" # Custom defined value
#   property_description      = "Role to assume during CI jobs"                                                                                                               # Custom defined value
#   property_value            = module.github_oidc_ci_assume_role.created_role_arn                                                                                            # Value retrieved from module outputs.tf
#   property_type             = "SecureString"
#   property_tags_environment = var.tag_environment # Value passed in via variables.tf
#   property_tags_origination = var.tag_origination_repo
#   property_tags_project     = var.project_name
# }

