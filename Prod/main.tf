module "QA" {
    source = "../modules/blog"

    environment = {
        name = "Prod"
        network_prefix = "10.2"
    }

    asg_min_size = 1
    asg_max_size = 1

    
}