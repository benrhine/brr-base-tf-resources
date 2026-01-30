
resource "random_string" "suffix" {
  length  = 8
  special = false
}

########################################################################################################################
# Should resource names be prefixed with their environment? This is an interesting question around environment design.
# Do you want a cluster per environment? e.g. dev-cluster, test-cluster ... or do you want something more like a cluster
# per account where the cluster in the dev account may hold both dev and test deployments, the cluster in non-prod may
# hold the uat and regression deployments.
########################################################################################################################
locals {
  resource_prefix = var.environment_prefix ? "${var.environment}-${var.project_name}-${var.project_id}" : "${var.project_name}-${var.project_id}"
}