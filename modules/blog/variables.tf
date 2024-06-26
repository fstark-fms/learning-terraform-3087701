variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "ami_filter" {
  description = "Name filter and owner of AMI"

  type = object({
    name = string
    owner = string
  })

  default = {
    name = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner = "979382823631" # Bitnami
  }
}

variable "environment" {
  description = "Development Environment"

  type = object ({
    name           = string
    network_prefix = string
    cert_subdomain = string
    zone_id        = string
  })

  default = {
    name           = "Development"
    network_prefix = "10.0"
    cert_subdomain = "blog-dev"
    zone_id = "Z05530962ORLJ19VPIYSO"
  }
}

variable "asg_min_size" {
  description = "min_size"
  default     = 1
}

variable "asg_max_size" {
  description = "max_size"
  default     = 2
}


