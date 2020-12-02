terraform {
  backend "remote" {
    organization = "Flexera-SE"

    workspaces {
      name = "Flexera-SE-API"
    }
  }
}

module "ec2-instance_example_basic" {
  source  = "terraform-aws-modules/ec2-instance/aws//examples/basic"
  version = "2.15.0"
}
