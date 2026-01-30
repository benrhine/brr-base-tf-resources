

########################################################################################################################
# S3 Policy Outputs
########################################################################################################################
output "github_oidc_connection_arn" {
  description = "ARN of GitHub OIDC Connection"
  value       = module.github_oidc_ci_assume_role.created_role_arn
}

output "admin_role_arn" {
  description = "ARN of GitHub OIDC Connection"
  value       = module.admin_assume_role.created_role_arn
}
########################################################################################################################
# SSM Property Outputs
########################################################################################################################
# output "created_ssm_properties" {
#   description = "System manager properties (SSM) created"
#   value = [for system_property in module.ssm : system_property.aws_ssm_property_arn]
# }

# output "aws_ssm_property_1_arn" {
#   description = "Created system manager property arn"
#   value       = module.ssm_1.aws_ssm_property_arn
# }
#
# output "aws_ssm_property_2_arn" {
#   description = "Created system manager property arn"
#   value       = module.ssm_2.aws_ssm_property_arn
# }

# output "aws_ssm_property_3" {
#   description = "Created system manager property arn"
#   value       = data.aws_ssm_parameter.external_service_role_principals.value
#   sensitive = true
# }
#
# output "aws_ssm_property_4" {
#   description = "Created system manager property arn"
#   value       = local.principals
#   sensitive = true
# }

########################################################################################################################
# IAM Roles Outputs
########################################################################################################################
# output "create_base_assumed_service_role_name" {
#   description = "Base role to be assumed name"
#   value       = module.base_assumed_service_role.created_role_name
# }
#
# output "create_base_assumed_service_role_arn" {
#   description = "Base role to be assumed ARN"
#   value       = module.base_assumed_service_role.created_role_arn
# }
#
# output "create_base_service_role_name" {
#   description = "Base service role name"
#   value       = module.base_service_role.created_role_name
# }
#
# output "create_base_service_role_arn" {
#   description = "Base service role ARN"
#   value       = module.base_service_role.created_role_arn
# }
#
# output "create_codebuild_service_role_name" {
#   description = "CodeBuild service role name"
#   value       = module.codebuild_service_role.created_role_name
# }
#
# output "create_codebuild_service_role_arn" {
#   description = "CodeBuild service role ARN"
#   value       = module.codebuild_service_role.created_role_arn
# }
#
# output "create_codepipeline_service_role_name" {
#   description = "CodePipeline service role name"
#   value       = module.codepipeline_service_role.created_role_name
# }
#
# output "create_codepipeline_service_role_arn" {
#   description = "CodePipeline service role ARN"
#   value       = module.codepipeline_service_role.created_role_arn
# }
#
# output "create_codepipeline_event_rule_role_name" {
#   description = "CodePipeline service role name"
#   value       = module.codepipeline_event_rule_role.created_role_name
# }
#
# output "create_codepipeline_event_rule_role_arn" {
#   description = "CodePipeline service role ARN"
#   value       = module.codepipeline_event_rule_role.created_role_arn
# }
#
# output "create_external_non_prod_service_role_name" {
#   description = "External role to be assumed at deployment time name"
#   value       = module.external_non_prod_service_role.created_role_name
# }
#
# output "create_external_non_prod_service_role_arn" {
#   description = "External role to be assumed at deployment time ARN"
#   value       = module.external_non_prod_service_role.created_role_arn
# }

# UNCOMMENT WHEN A PROD ACCOUNT IS AVAILABLE
# output "create_external_prod_service_role_name" {
#   description = "External role to be assumed at deployment time name"
#   value       = module.external_prod_service_role.created_role_name
# }
#
# output "create_external_prod_service_role_arn" {
#   description = "External role to be assumed at deployment time ARN"
#   value       = module.external_prod_service_role.created_role_arn
# }

########################################################################################################################
# IAM Policy Outputs
########################################################################################################################
# output "created_iam_policies" {
#   description = "IAM policies created"
#   value = [for policy in module.iam_policies : policy.tf_policy_arn]
# }
#
# output "created_iam_external_non_prod_policies" {
#   description = "External IAM policies created"
#   value = [for policy in module.iam_external_non_prod_policies : policy.tf_policy_arn]
# }

# UNCOMMENT WHEN A PROD ACCOUNT IS AVAILABLE
# output "created_iam_external_prod_policies" {
#   description = "External IAM policies created"
#   value = [for policy in module.iam_external_prod_policies : policy.tf_policy_arn]
# }

########################################################################################################################
# IAM Policy Attachments Outputs - Not sure that putting this out would have any value
########################################################################################################################
# output "assumed_service_role_policy_attachment_1" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.assumed_service_role_policy_attachment_1
# }
#
# output "assumed_service_role_policy_attachment_2" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.assumed_service_role_policy_attachment_2
# }
#
# output "base_service_role_policy_attachment_1" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.base_service_role_policy_attachment_1
# }
#
# output "base_service_role_policy_attachment_2" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.base_service_role_policy_attachment_2
# }
#
# output "base_service_role_policy_attachment_3" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.base_service_role_policy_attachment_3
# }
#
# output "base_service_role_policy_attachment_4" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.base_service_role_policy_attachment_4
# }
#
# output "base_service_role_policy_attachment_5" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.base_service_role_policy_attachment_5
# }
#
# output "codebuild_service_role_policy_attachment_1" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codebuild_service_role_policy_attachment_1
# }
#
# output "codebuild_service_role_policy_attachment_2" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codebuild_service_role_policy_attachment_2
# }
#
# output "codebuild_service_role_policy_attachment_3" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codebuild_service_role_policy_attachment_3
# }
#
# output "codebuild_service_role_policy_attachment_4" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codebuild_service_role_policy_attachment_4
# }
#
# output "codebuild_service_role_policy_attachment_5" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codebuild_service_role_policy_attachment_5
# }
#
# output "codebuild_service_role_policy_attachment_6" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codebuild_service_role_policy_attachment_6
# }
#
# output "codebuild_service_role_policy_attachment_7" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codebuild_service_role_policy_attachment_7
# }
#
# output "codebuild_service_role_policy_attachment_8" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codebuild_service_role_policy_attachment_8
# }
#
# output "codebuild_service_role_policy_attachment_9" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codebuild_service_role_policy_attachment_9
# }
#
# output "codepipeline_service_role_policy_attachment_1" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codepipeline_service_role_policy_attachment_1
# }
#
# output "codepipeline_service_role_policy_attachment_2" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codepipeline_service_role_policy_attachment_2
# }
#
# output "codepipeline_service_role_policy_attachment_3" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codepipeline_service_role_policy_attachment_3
# }
#
# output "codepipeline_event_rule_role_policy_attachment_1" {
#   description = "ARN of successful policy attachment"
#   value       = module.iam_policy_attachments.codepipeline_event_rule_role_policy_attachment_1
# }

########################################################################################################################
# CodeBuild Outputs
########################################################################################################################
# output "aws_codebuild_account_resources_disaster_recovery_name" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_disaster_recovery.aws_codebuild_project_name
# }
#
# output "aws_codebuild_account_resources_disaster_recovery_arn" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_disaster_recovery.aws_codebuild_project_arn
# }
#
# output "aws_codebuild_account_resources_properties_local_deploy_name" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_properties_deploy.aws_codebuild_project_name
# }
#
# output "aws_codebuild_account_resources_properties_local_deploy_arn" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_properties_deploy.aws_codebuild_project_arn
# }
#
# output "aws_codebuild_account_resources_properties_local_remove_name" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_properties_remove.aws_codebuild_project_name
# }
#
# output "aws_codebuild_account_resources_properties_local_remove_arn" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_properties_remove.aws_codebuild_project_arn
# }
#
# output "aws_codebuild_account_resources_chatbot_cross_account_deploy_name" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_chatbot_cross_account_deploy.aws_codebuild_project_name
# }
#
# output "aws_codebuild_account_resources_chatbot_cross_account_deploy_arn" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_chatbot_cross_account_deploy.aws_codebuild_project_arn
# }
#
# output "aws_codebuild_account_resources_chatbot_cross_account_remove_name" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_chatbot_cross_account_remove.aws_codebuild_project_name
# }
#
# output "aws_codebuild_account_resources_chatbot_cross_account_remove_arn" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_chatbot_cross_account_remove.aws_codebuild_project_arn
# }
#
# output "aws_codebuild_account_resources_repo_notifications_local_deploy_name" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_repo_notifications_deploy.aws_codebuild_project_name
# }
#
# output "aws_codebuild_account_resources_repo_notifications_local_deploy_arn" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_repo_notifications_deploy.aws_codebuild_project_arn
# }
#
# output "aws_codebuild_account_resources_repo_notifications_local_remove_name" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_repo_notifications_remove.aws_codebuild_project_name
# }
#
# output "aws_codebuild_account_resources_repo_notifications_local_remove_arn" {
#   description = "Returning CodeBuild Project"
#   value       = module.build_account_resources_repo_notifications_remove.aws_codebuild_project_arn
# }

# ########################################################################################################################
# # CodePipeline Outputs
# ########################################################################################################################
# output "aws_codepipeline_project_name" {
#   description = "Returning CodeBuild Project"
#   value       = module.codepipeline.aws_codepipeline_project_name
# }
#
# output "aws_codepipeline_project_arn" {
#   description = "Returning CodeBuild Project"
#   value       = module.codepipeline.aws_codepipeline_project_arn
# }
#
# ########################################################################################################################
# # Event Rule Outputs
# ########################################################################################################################
# output "event_rule_name" {
#   description = "Event rule name"
#   value       = module.event_rule.event_rule_name
# }
#
# output "event_rule_arn" {
#   description = "ARN of created event rule"
#   value       = module.event_rule.event_rule_arn
# }
#
# output "event_target_target_id" {
#   description = "ARN of event rule target attachment"
#   value       = module.event_rule.event_target_target_id
# }
#
# output "event_target_arn" {
#   description = "ARN of event rule target attachment"
#   value       = module.event_rule.event_target_arn
# }