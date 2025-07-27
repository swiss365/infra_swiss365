module "guac_lb" {
  source            = "./modules/lb_guacamole"
  name              = "${var.customer_id}_guacamole_lb"
  target_server_ids = [module.desktop_pool_host.server_id]
  network_id        = hcloud_network.swiss365_net.id
}
