terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "remote" {
    organization = "impara8"

    workspaces {
      name = "tf-engneed"
    }
  }
}

locals {
  env    = "dev-koichi"
  region = "ap-northeast-1"
  tagNames = {
    "aws-exam-resource" : true,
    "Name" : "eng-exam"
  }
  vpc_cidr = "10.13.0.0/16"
  public_subnets = {
    "az-a" : {
      "cidr" : "10.13.0.0/24",
      "az" : "ap-northeast-1a"
    },
    "az-c" : {
      "cidr" : "10.13.1.0/24",
      "az" : "ap-northeast-1c"
    },
  }
  private_subnets = {
    "az-a" : {
      "cidr" : "10.13.10.0/24",
      "az" : "ap-northeast-1a"
    },
    "az-c" : {
      "cidr" : "10.13.11.0/24",
      "az" : "ap-northeast-1c"
    },
  }
  secure_subets = {
    "az-a" : {
      "cidr" : "10.13.20.0/24",
      "az" : "ap-northeast-1a"
    },
    "az-c" : {
      "cidr" : "10.13.21.0/24",
      "az" : "ap-northeast-1c"
    },
  }
  instance_type = "t3.small"
  #image_id      = "ami-01e94099fb3acf7fa"
  image_id = "ami-04671bc5dcaeedf5b"

  domain = "00111.engineed-exam.com"

  instance_class = "db.t3.small"
}
provider "aws" {
  region = local.region
  assume_role {
    role_arn = var.assume_role
  }
}

provider "aws" {
  alias  = "us_region"
  region = "us-east-1"
  assume_role {
    role_arn = var.assume_role
  }
}

module "network" {
  source          = "../../modules/vpc/"
  vpc_cidr        = local.vpc_cidr
  tagNames        = local.tagNames
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  secure_subets   = local.secure_subets
}

module "service-servers" {
  source        = "../../modules/autoscaling/"
  image_id      = local.image_id
  instance_type = local.instance_type
  user_data     = "/Volumes/exvol01/engineed/terraform/data/userdata.txt"
  security_groups = [
    module.web_sec_group_80.sec_group.id,
    module.internal_ssh.sec_group.id,
    module.db_sec_group_3306.sec_group.id,
  ]
  min_size             = 4
  max_size             = 6
  tagNames             = local.tagNames
  azs                  = module.network.private_ids
  launch_name          = "service-servers"
  alb_target_group_arn = module.alb_https.alb_target_group_arn
  topic_arn            = module.sns.topic_arn
}
module "manage-server" {
  source        = "../../modules/autoscaling/"
  image_id      = local.image_id
  instance_type = local.instance_type
  user_data     = "/Volumes/exvol01/engineed/terraform/data/userdata.txt"
  security_groups = [
    module.web_sec_group_80.sec_group.id,
    module.internal_ssh.sec_group.id,
    module.db_sec_group_3306.sec_group.id,
  ]
  min_size             = 1
  max_size             = 1
  tagNames             = local.tagNames
  azs                  = module.network.private_ids
  launch_name          = "manage-server"
  alb_target_group_arn = module.alb_https.alb_target_group_arn_manage
  topic_arn            = module.sns.topic_arn
}


module "web_sec_group_80" {
  source      = "../../modules/secgroup/"
  name        = "web_sec_group_80"
  server_port = 80
  tagNames    = local.tagNames
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "tcp"
  vpc_id      = module.network.vpc_id
}
module "web_sec_group_443" {
  source      = "../../modules/secgroup/"
  name        = "web_sec_group_443"
  tagNames    = local.tagNames
  server_port = 443
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "tcp"
  vpc_id      = module.network.vpc_id
}

module "db_sec_group_3306" {
  source      = "../../modules/secgroup/"
  name        = "db_sec_group_3306"
  tagNames    = local.tagNames
  server_port = 3306
  cidr_blocks = [local.vpc_cidr]
  protocol    = "tcp"
  vpc_id      = module.network.vpc_id
}

module "internal_ssh" {
  source      = "../../modules/secgroup/"
  name        = "internal_ssh"
  tagNames    = local.tagNames
  server_port = 22
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "tcp"
  vpc_id      = module.network.vpc_id
}

module "acm" {
  source = "../../modules/acm/"
  providers = {
    aws = aws.us_region
  }
  domain   = local.domain
  tagNames = local.tagNames
}
module "alb_https" {
  source   = "../../modules/alb/"
  tagNames = local.tagNames
  securitygroups = [
    module.web_sec_group_80.sec_group.id,
    module.web_sec_group_443.sec_group.id,
    module.internal_ssh.sec_group.id,
    module.db_sec_group_3306.sec_group.id,
  ]
  subnets                     = module.network.public_ids
  vpc_id                      = module.network.vpc_id
  domain                      = local.domain
  aws_acm_certificate         = module.acm.aws_acm_certificate
  aws_cloudfront_distribution = module.cdn.aws_cloudfront_distribution
}

module "rds" {
  source         = "../../modules/rds/"
  tagNames       = local.tagNames
  subnets        = module.network.secure_ids
  instance_class = local.instance_class
  username       = var.username
  password       = var.password
  vpc_security_group_ids = [
    module.db_sec_group_3306.sec_group.id,
    module.internal_ssh.sec_group.id
  ]
}

module "bastion" {
  source        = "../../modules/ec2/"
  ami           = local.image_id
  instance_type = local.instance_type
  keyname       = "eng-test"
  subnet_id     = module.network.public_ids.0
  vpc_security_group_ids = [
    module.web_sec_group_80.sec_group.id,
    module.internal_ssh.sec_group.id,
    module.db_sec_group_3306.sec_group.id,
  ]
  tagNames             = local.tagNames
  user_data            = "/Volumes/exvol01/engineed/terraform/data/userdata.txt"
  iam_instance_profile = module.iam.cwinstanceprofilename
}

module "cdn" {
  source              = "../../modules/cdn"
  tagNames            = local.tagNames
  acm_certificate_arn = module.acm.aws_acm_certificate.arn
  alb_domain_name     = module.alb_https.alb.dns_name
  domain              = local.domain
  web_acl_id          = module.waf.aws_wafv2_web_acl.arn
}

module "waf" {
  source   = "../../modules/waf/"
  tagNames = local.tagNames
  providers = {
    aws = aws.us_region
  }
}

module "sec" {
  source   = "../../modules/security/"
  tagNames = local.tagNames
  env      = local.env
}

module "iam" {
  source   = "../../modules/iam/"
  tagNames = local.tagNames
}

module "monitoring" {
  source               = "../../modules/monitoring"
  AutoScalingGroupName = module.service-servers.autoscalingGroupname
  alarm_actions        = [module.service-servers.cpuscaleArn]
}

module "s3" {
  source   = "../../modules/sitaticSite_s3/"
  tagNames = local.tagNames
  env      = local.env
}

module "sns" {
  source   = "../../modules/sns/"
  tagNames = local.tagNames
}
