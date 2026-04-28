terraform {
  backend "s3" {
    bucket = "ecs-v3-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-2"
    state_lock = true
  }
}