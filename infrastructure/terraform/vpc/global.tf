data "terraform_remote_state" "vpc" {
  backend     = "s3"

  config {
    bucket  = "infra-problem"
    key     = "infra-problem-vpc"
    region  = "eu-west-2"
  }
}

data "terraform_remote_state" "jenkins" {
  backend     = "s3"

  config {
    bucket  = "infra-problem"
    key     = "infra-problem-jenkins"
    region  = "eu-west-2"
  }
}

# PORTS

variable "jenkins_port" {
  default = 8080
}

variable "bitbucket_port" {
  default = 28
}

variable "ssh_port" {
  default = 22
}

variable "http_port" {
  default = 80
}

variable "https_port" {
  default = 443
}

# VPC CIDR's

variable "infra_problem_vpc_cidr_range" {
  default = "10.1.0.0/16"
}

# SUBNET CIDR's

variable "public_a_cidr_range" {
  default = "10.1.5.0/24"
}

variable "public_b_cidr_range" {
  default = "10.1.6.0/24"
}

variable "private_a_cidr_range" {
  default = "10.1.3.0/24"
}

variable "private_b_cidr_range" {
  default = "10.1.4.0/24"
}


# IPs

variable "office_cidr_range" {
  default = "86.0.212.176/32"
}

# Bitbucket
#104.192.143.0/24
#34.198.203.127/32
#34.198.178.64/32
#34.198.32.85/32
