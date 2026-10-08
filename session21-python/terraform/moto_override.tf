# Points the AWS provider at Moto, a free local AWS emulator (zero cost).
# Delete this one file and the same code runs against real AWS.
provider "aws" {
  region     = var.aws_region
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2  = "http://127.0.0.1:5055"
    eks  = "http://127.0.0.1:5055"
    iam  = "http://127.0.0.1:5055"
    kms  = "http://127.0.0.1:5055"
    logs = "http://127.0.0.1:5055"
    sts  = "http://127.0.0.1:5055"
  }
}
