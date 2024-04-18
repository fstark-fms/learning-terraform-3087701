output "environment_url" {
    value = module.blog_alb.lb_dns_name
    env_url = module.blog_alb.environment_url
    url = module.blog_alb.url
}