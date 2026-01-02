terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    
   
    }
    
  }
}
provider "aws" {
  region = "ap-northeast-2"
}


module "vpc" {
  source = "./modules/vpc"
}
module "subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
}  

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
}  

module "iamrole" {
  source = "./modules/iamrole"
}  

module "route" {
  source = "./modules/route"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.subnet.public_subnet_ids
  igw_id = module.igw.igw_id
  # nat_id = module.nat.nat_id
  # nat_network_interface_id = module.nat.nat_network_interface_id
  # private_subnet_ids = module.subnet.private_subnet_ids
}
module "rds"{
  source = "./modules/rds"
  db_subnet_ids_list     = module.subnet.db_subnet_ids_list
  rds_sg_id = module.sg.rds_sg_id
  instance_class    = var.instance_class
  db_username          = var.db_username
  db_password          = var.db_password

}

module "instance" {
  source = "./modules/instance"
  instance_type = var.instance_type
  public_subnet_ids = module.subnet.public_subnet_ids
  ec2_sg_id = module.sg.ec2_sg_id
  app_key_name=module.key.app_key_name
  app_instance_profile = module.iamrole.app_instance_profile
} 

module "key"{
  source="./modules/key"
}

module "sg"{
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.subnet.public_subnet_ids
  # private_subnet_ids = module.subnet.private_subnet_ids
}

module "sns"{
  source = "./modules/sns"

}

module "cloudwatch"{
  source = "./modules/cloudwatch"
  alerts_topic_arn = module.sns.alerts_topic_arn
}



# module "nat" {
#   source                = "./modules/nat"
#   vpc_id                = module.vpc.vpc_id
#   public_subnet_id     = module.subnet.public_subnet_id
#   nat_sg_id = module.sg.nat_sg_id
# }

