output "environment_url" {
    value = module.blog_alb.lb_dns_name
    url = "${var.environment.cert_subdomain}.fmsvisitor.com"
}