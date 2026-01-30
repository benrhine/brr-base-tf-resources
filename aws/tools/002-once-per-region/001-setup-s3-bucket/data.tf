
# THESE CALLS ARE PULLING THE DATA FROM THE LOCALLY LOGGED IN ACCOUNT - I.E. IF YOU ARE LOGGED INTO US-WEST-2 IT WILL
# RETURN US-WEST-2

# Retrieve the current aws account
data "aws_caller_identity" "current" {}

# Retrieve the current aws region
data "aws_region" "current" {}

# CANT DO THIS YET AS NO BUCKET EXISTS
# data "terraform_remote_state" "platform" {
#   backend = "s3"
#   config = {
#     bucket = "tf-states"
#     key    = "platform/iam.tfstate"
#     region = "us-east-1"
#   }
# }
#
# locals {
#   role_name = data.terraform_remote_state.platform.outputs.github_actions_role_name
# }