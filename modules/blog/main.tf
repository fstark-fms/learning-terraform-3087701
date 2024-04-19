data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner] 
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets  = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24", "${var.environment.network_prefix}.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = var.environment.name == "Development2" ? "Development" : var.environment.name
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  name = "${var.environment.name}_blog_new"
  
  vpc_id = module.blog_vpc.vpc_id

  ingress_rules = ["http-80-tcp","https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
  egress_cidr_blocks = ["10.0.0.0/24"]
}

module "autoscaling" {
  source   = "terraform-aws-modules/autoscaling/aws"
  version  = "7.4.0"

  name     = "${var.environment.name}-blog-autoscale"
  min_size = var.asg_min_size
  max_size = var.asg_max_size

  vpc_zone_identifier = module.blog_vpc.public_subnets
  target_group_arns   = module.blog_alb.target_groups["ex-instance"].arn

  security_groups     = [module.blog_sg.security_group_id]
  
  image_id      = data.aws_ami.app_ami.id
  instance_type = var.instance_type
}

module "blog_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  zone_id = "Z05530962ORLJ19VPIYSO"

  domain_name  = "${var.environment.cert_subdomain}.devqafms.com"

  wait_for_validation = true
}


module "blog_alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name    = "${var.environment.name}-fsblog"

  load_balancer_type = "application"
 
  vpc_id  = module.blog_vpc.vpc_id
  subnets = module.blog_vpc.public_subnets
  security_groups = [module.blog_sg.security_group_id]


  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.blog_acm.acm_certificate_arn

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix      = "fsblog"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      create_attachment = false
    }
  }

  tags = {
    Environment = var.environment.name == "Development2" ? "Development" : var.environment.name
    Project     = "Blog_FS_mod"
  }
}

resource "aws_lb_target_group_attachment" "blog_target_group" {
  for_each = {for k,v in module.blog_alb.target_groups: k => v}

  target_group_arn = each.value.arn
  target_id        = each.value.id
  port             = 80
}

