terraform {
  backend "s3" {
    bucket = "terraform-backend-tfstate-412058342959-eu-west-2-an"
    key    = "${terraform.workspace}/terraform.tfstate"
    region = "eu-west-2"
    state_lock = true
    endpoint                   = "http://localhost:4566"
  }
}