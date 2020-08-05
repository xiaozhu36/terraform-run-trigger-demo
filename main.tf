variable "region" {
  default = "cn-hangzhou"
}
provider "alicloud" {
  region = var.region
}
data "alicloud_vpcs" "default" {
  is_default = true
}

module "service_sg_with_multi_cidr" {
  source = "alibaba/security-group/alicloud"
  region = var.region

  name        = "terraform-run-trigger-demo"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = data.alicloud_vpcs.default.ids.0

  ingress_cidr_blocks = ["10.10.0.0/16"]
  ingress_rules       = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16,10.11.0.0/16,10.12.0.0/16"
      priority    = 2
    },
    {
      rule        = "postgresql-tcp"
      priority    = 2
      cidr_blocks = "10.13.0.0/16,10.14.0.0/16"
    },
    {
      // Using ingress_cidr_blocks to set cidr_blocks
      rule = "postgresql-tcp"
    },
  ]
  egress_cidr_blocks = ["10.10.0.0/16"]
  egress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      priority    = 1
      cidr_blocks = "10.13.0.0/16,10.14.0.0/16"
    },
    {
      // Using egress_cidr_blocks to set cidr_blocks
      rule = "postgresql-tcp"
    },
  ]
}