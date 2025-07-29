module "guac_lb" {
  source            = "./modules/lb_guacamole"
  name              = "${var.customer_id}-guacamole-lb"
  target_server_ids = [module.desktop_pool_host.server_id]
  network_id        = hcloud_network.swiss365_net.id
  labels = {
    customer = var.customer_id
  }
}
