
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false # Exclude uppercase characters
  # numeric = false # Exclude numeric characters
}

locals {
  convert_to_underscores = replace(var.git_repo_name, "-", "_")
}