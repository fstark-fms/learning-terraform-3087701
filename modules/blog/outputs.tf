output "environment_alb_url" {
    value = module.blog_alb.dns_name
}

output "environment_url" {
    value = module.blog_acm.distinct_domain_names
}