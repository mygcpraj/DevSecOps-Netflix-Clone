terraform {
  backend "s3" {
    bucket = "noobin-jenkins-bucket"
    key    = "eks/terraform-tfstate"
    region = "us-east-1"
  }
}