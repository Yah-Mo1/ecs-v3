terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.41.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "eu-west-2"
}

# provider "aws" {
#   region = "eu-west-2"
#   skip_credentials_validation = true
#   skip_requesting_account_id = true
#   skip_metadata_api_check = true

#   endpoints {
#     ec2                        = "http://localhost:4566"
#     sts                        = "http://localhost:4566"
    
#   }
# }