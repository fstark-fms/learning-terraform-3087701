output "environment_alb_url" {
    value = module.blog_alb.dns_name
}

output "environment_alb_target_groups" {
    value = module.blog_alb.target_groups
}

output "environment_alb_target_group_arns" {
    value = module.blog_alb.target_group_arns
}


output "environment_url" {
    value = module.blog_acm.distinct_domain_names
}