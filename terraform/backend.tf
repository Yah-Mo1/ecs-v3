//  TODO: Later replace with terraform workspace
terraform {
  backend "s3" {
    bucket = "terraform-backend-tfstate-412058342959-eu-west-2-an"
    key    = "key-an/terraform.tfstate"
    region = "eu-west-2"
    encrypt      = true  
    use_lockfile = true
  }
}


// During development, use the following backend configuration
# terraform {
#   backend "s3" {
#     bucket = "terraform-backend-tfstate-412058342959-eu-west-2-an"
#     key    = "${terraform.workspace}/terraform.tfstate"
#     region = "eu-west-2"
#     state_lock = true
#   }
# }