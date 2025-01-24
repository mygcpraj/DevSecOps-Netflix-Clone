terraform {
  backend "s3" {
    bucket = "noobin-jenkins-bucket"
    key    = "jenkins/terraform-tfstate"
    region = "us-east-1"
  }
}