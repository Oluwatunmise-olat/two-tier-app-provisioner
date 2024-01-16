
provider "aws" {
  # Wehn using Localstack and not aws configurations
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  region = "us-east-1"


  endpoints {
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    sqs = "http://localhost:4566"
    eks = "http://localhost:4566"
  }
}