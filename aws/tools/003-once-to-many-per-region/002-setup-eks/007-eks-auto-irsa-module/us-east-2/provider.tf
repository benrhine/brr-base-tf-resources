# What cloud platform are you using and what is the default region
# See https://stackoverflow.com/questions/71347024/terraform-file-for-aws-s3-bucket-keeps-getting-error-invalid-provider-configura
# for notes on alias
provider "aws" {
  # alias   = "brr-tools"
  region  = var.aws_region
  # ChatGPT warns strongly against having the profile key here. However, I find that if you need to execute locally that
  # this key is required. This has been made dynamic with the tfvars vile and in the CI should accept a null without issue.
  profile = var.aws_profile
}
