terraform {
  backend "s3" {
    bucket  = "infra-problem"
    key     = "infra-problem-app"
    region  = "eu-west-2"
    encrypt = true
  }
}
