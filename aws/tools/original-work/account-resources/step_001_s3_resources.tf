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
# resource "random_string" "suffix" {
#   length  = 8
#   special = false
#   upper   = false # Exclude uppercase characters
#   # numeric = false # Exclude numeric characters
# }
#
# module "s3_tf_state_bucket" {
#   source                        = "git::https://github.com/benrhine/brr-s3-module.git?ref=v0.0.1.7"                                          # Where to find the module
#   ######################################################################################################################
#   #   aws_region                    = data.aws_region.current.name                            # Value retrieved in data.tf
#   #   aws_account                   = data.aws_caller_identity.current.account_id             # Value retrieved in data.tf
#   #   project_name                  = var.project_name                                        # Value passed in via variables.tf
#   # Custom defined value
#   create_bucket_name            = "${var.framework_prefix}-state-${random_string.suffix.result}"
#   s3_tags_environment           = var.tag_environment_tools                                 # Value passed in via variables.tf
#   s3_tags_origination           = var.tag_origination_repo
#   s3_tags_project               = var.project_name
# }

# SERVERLESS FRAMEWORK EXAMPLE OF THIS MODULE
#
#  DeployBucket:                                                   # Create S3 bucket to contain ALL sls deployments
#    Type: AWS::S3::Bucket                                         # Resource type
#    DeletionPolicy: Retain                                        # DO NOT DELETE IF CLOUDFORMATION STACK IS REMOVED
#    Properties:
#      BucketName: !Sub ${AccountName}-${AWS::Region}-${S3DeploymentBucket}  # Set bucket name from configurable parameter
#      BucketEncryption:                                           # Configure bucket encryption
#        ServerSideEncryptionConfiguration:
#          - ServerSideEncryptionByDefault:
#              SSEAlgorithm: AES256
#      PublicAccessBlockConfiguration:                             # Configure public access - make sure all public access is blocked
#        BlockPublicAcls: true
#        BlockPublicPolicy: true
#        IgnorePublicAcls: true
#        RestrictPublicBuckets: true

########################################################################################################################
# S3 Policies Module Declaration: This module is used to create S3 bucket policies. In the case of this application this
# declaration is being used to create a policy for the bucket created from the "S3 Module" declaration to deny outside
# access in most cases.
#
# NOTE: THE DEPENDS ON BLOCK.
# NOTE2: THIS MODULE SHOULD BE REUSABLE
########################################################################################################################
# module "s3_policies" {
#   source                        = "git::https://github.com/benrhine/brr-s3-policy-module/releases/tag/v0.0.1.1"                                 # Where to find the module
#   ######################################################################################################################
#   aws_region                    = data.aws_region.current.name                            # Value retrieved in data.tf
#   aws_account                   = data.aws_caller_identity.current.account_id             # Value retrieved in data.tf
#   framework_prefix              = var.framework_prefix
#   account_tools                 = var.account_tools
#   account_non_prod              = var.account_non_prod
#   account_prod                  = var.account_prod
#   project_name                  = var.project_name                                        # Value passed in via variables.tf
#   bucket_arn                    = module.s3.aws_s3_bucket.arn                             # Value retrieved from module outputs.tf
#   bucket_id                     = module.s3.aws_s3_bucket.id                              # Value retrieved from module outputs.tf
#   bucket_policy_identifiers_name= module.external_non_prod_service_role.created_role.name
#
#   # s3_policies module instantiation depends on the following modules; resources in modules declared within "depends_on"
#   # must complete instantiation prior to s3_policies instantiation.
#   depends_on = [
#     module.s3
#   ]
# }

# SERVERLESS FRAMEWORK EXAMPLE OF THIS MODULE
#
#  DeploymentBucketPolicy:                                         # Resource name
#    Type: AWS::S3::BucketPolicy                                   # Resource type
#    DeletionPolicy: Retain                                        # DO NOT DELETE IF CLOUDFORMATION STACK IS REMOVED
#    DependsOn: DeployBucket                                       # Policy creation is dependent on bucket being previously created
#    Properties:
#      Bucket: !Sub ${AccountName}-${AWS::Region}-${S3DeploymentBucket}  # Set bucket name from configurable parameter
#      PolicyDocument:
#        Statement:
#          - Action:
#              - s3:GetLifecycleConfiguration
#              - s3:ListBucket
#              - s3:Get*
#              - s3:PutObject
#              - s3:DeleteObject
#            Resource:                                             # Limit permissions to THIS bucket
#              - !Sub arn:aws:s3:::${AccountName}-${AWS::Region}-${S3DeploymentBucket}
#              - !Sub arn:aws:s3:::${AccountName}-${AWS::Region}-${S3DeploymentBucket}/*
#            Effect: Allow
#            Principal:
#              AWS:
#                - arn:aws:iam::NP-ACCOUNT-NUM:role/sls-external-service-role
#                - arn:aws:iam::P-ACCOUNT-NUM:role/sls-external-service-role

# # Enable versioning on bucket that maintains terraform state
# resource "aws_s3_bucket_versioning" "versioning_tf_state" {
#   bucket = module.s3.aws_s3_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }