# What cloud platform are you using and what is the default region
# See https://stackoverflow.com/questions/71347024/terraform-file-for-aws-s3-bucket-keeps-getting-error-invalid-provider-configura
# for notes on alias
provider "aws" {
  # alias   = "brr-tools"
  region  = "us-east-2"
  # shared_config_files = ["~/.aws/config"]
  # profile = "brr-tools-admin"
}

# provider "aws" {
#   alias   = "brr-np"
#   region  = "us-east-2"
#   profile = "brr-np-admin"
# }

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  # config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  }
}


# TODO
# I believe these will have to be modified to receive client/secret from buildspec
# only reason the main one works this way is because it is initially executed from local