output "environment_alb_url" {
    value = module.blog_alb.lb_dns_name
}

output "environment_url" {
    value = module.blog_alb.environment_url
}

output "url" {
    value = module.blog_alb.url
}