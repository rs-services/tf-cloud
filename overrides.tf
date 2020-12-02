provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  id = "vpc-874ba2ee"
}