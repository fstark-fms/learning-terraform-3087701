module "Development2" {
    source = "../modules/blog"

    environment = {
        name = "Development2"
        network_prefix = "10.5"
    }

    asg_min_size = 1
    asg_max_size = 2
    
}