module "network" {
  source     = "./network"
  aws_region = "us-east-1"
}

module "ec2" {
  source                      = "./ec2"
  aws_region                  = "us-east-1"
  two_tier_public_subnet_1_id = module.network.public_subnet_one_id
  two_tier_public_subnet_2_id = module.network.public_subnet_two_id
  web_sg_id                   = module.network.web_sg_id
  db_sg_id                    = module.network.db_sg_id
  db_password                 = var.db_password
  db_username                 = var.db_username
}