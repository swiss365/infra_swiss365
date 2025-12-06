# load_balancer.tf - Load balancer configuration
# Updated to point to control_node instead of desktop_pool

module "guac_lb" {
  source            = "./modules/lb_guacamole"
  name              = "${var.customer_id}-guacamole-lb"
  # IMPORTANT: Changed to control_node which runs Guacamole
  target_server_ids = [module.control_node.server_id]
  network_id        = hcloud_network.swiss365_net.id
  domain_name       = var.guacamole_domain
  labels = {
    customer = var.customer_id
  }
}
