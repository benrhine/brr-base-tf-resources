# What cloud platform are you using and what is the default region
# See https://stackoverflow.com/questions/71347024/terraform-file-for-aws-s3-bucket-keeps-getting-error-invalid-provider-configura
# for notes on alias
provider "aws" {
  # alias   = "brr-tools"
  region = "us-east-2"
  # shared_config_files = ["~/.aws/config"]
  profile = "brr-tools-admin"
}

provider "github" {
  owner = "benrhine"
  token = var.github_token
}