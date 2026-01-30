

# Create an IAM role to be assumed by GitHub Action
# checkov:skip=CKV_TF_1 "Using pinned module, ignore false positive"
module "github_oidc_ci_assume_role" {
  source = "git::https://github.com/benrhine/brr-iam-roles-module.git?ref=v0.0.1.1" # Where to find the module
  ######################################################################################################################   # Value passed in via variables.tf
  # iam_role_name            = "${var.iam_role_name}_${local.convert_to_underscores}"
  iam_role_name          = "${var.iam_role_name}_${random_string.suffix.result}"
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
  iam_role_name          = "${var.iam_role_name_2}_${random_string.suffix.result}"
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

## "arn:aws:sts::792981815698:assumed-role/github_oidc_ci_assume_role/21009592007-1

# aws eks associate-access-policy \
# --cluster-name my-eks-cluster-example-1-xpmJzaaq \
# --principal-arn arn:aws:iam::792981815698:role/eks-role \
# --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
# --access-scope type=cluster


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

