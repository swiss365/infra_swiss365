module "guac_lb" {
  source            = "./modules/lb_guacamole"
  name              = "guacamole_lb"
  target_server_ids = [module.desktop_pool_host.hcloud_server.this.id]
}
