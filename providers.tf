provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "kutt-s3-tf-state"
    key    = "kutt/terraform.tfstate"
    region = "eu-central-1"
  }
}
