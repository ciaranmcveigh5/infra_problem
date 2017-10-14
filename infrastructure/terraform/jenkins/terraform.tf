terraform {
  backend "s3" {
    bucket  = "infra-problem"
    key     = "infra-problem-jenkins"
    region  = "eu-west-2"
    encrypt = true
  }
}
