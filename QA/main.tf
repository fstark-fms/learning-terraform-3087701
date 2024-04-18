module "QA" {
    source = "../modules/blog"

    environment = {
        name = "QA"
        network_prefix = "10.1"
        cert_subdomain = "blog-qa"
    }

    asg_min_size = 1
    asg_max_size = 2

    
}