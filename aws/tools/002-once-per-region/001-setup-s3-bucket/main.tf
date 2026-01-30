
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

# checkov:skip=CKV_TF_1 "Using pinned module, ignore false positive"
module "s3_tf_state_bucket" {
  source = "git::https://github.com/benrhine/brr-s3-module.git?ref=v0.0.1.7" # Where to find the module
  ######################################################################################################################
  #   aws_region                    = data.aws_region.current.name                            # Value retrieved in data.tf
  #   aws_account                   = data.aws_caller_identity.current.account_id             # Value retrieved in data.tf
  #   project_name                  = var.project_name                                        # Value passed in via variables.tf
  # Custom defined value
  create_bucket_name  = "${var.framework_prefix}-state-${var.project_postfix}"
  s3_tags_environment = var.tag_environment_tools # Value passed in via variables.tf
  s3_tags_origination = var.tag_origination_repo
  s3_tags_project     = var.project_name
}

# Enable versioning on bucket that maintains terraform state
resource "aws_s3_bucket_versioning" "versioning_tf_state" {
  bucket = module.s3_tf_state_bucket.aws_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
