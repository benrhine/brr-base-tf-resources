data "aws_iam_policy_document" "github_oidc_ci_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    # this causes the job to fail
    # condition {
    #   test     = "StringEquals"
    #   variable = "token.actions.githubusercontent.com:ref"
    #   values   = ["refs/heads/main"]
    # }

    # This will require additional configuration for different branches
    # CHOOSE THIS OPTION IF YOU ARE NOT USING GITHUB ENVIRONMENTS
    # condition {
    #   test     = "StringLike"
    #   variable = "token.actions.githubusercontent.com:sub"
    #   values   = ["repo:${var.git_org_name}/${var.git_repo_name}:ref:refs/heads/main"]
    # }

    # CHOOSE THIS OPTION IF YOU ARE USING GITHUB ENVIRONMENTS
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # values   = ["repo:${var.git_org_name}/${var.git_repo_name}:environment:${var.git_env_name}"]
      values = ["repo:${var.git_org_name}/${var.git_repo_name}:ref:refs/heads/main"]
    }
  }
}
#
# git@github.com:benrhine/spring-boot-with-aws-secrets-manager.git

# "Condition": {
#   "ForAllValues:StringEquals": {
#     "token.actions.githubusercontent.com:ref": "refs/heads/dev",
#     "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
#   },
#   "StringLike": {
#     "token.actions.githubusercontent.com:sub": "repo:johncolmdoyle/holycitypaddle-code:*"
#   },
# }