
# THESE CALLS ARE PULLING THE DATA FROM THE LOCALLY LOGGED IN ACCOUNT - I.E. IF YOU ARE LOGGED INTO US-WEST-2 IT WILL
# RETURN US-WEST-2

# Retrieve the current aws account
data "aws_caller_identity" "current" {}

# Retrieve the current aws region
data "aws_region" "current" {}