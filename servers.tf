module "control_node" {
  source       = "./modules/server_common"
  name         = "control_node"
  server_type  = "cpx31"
  image        = var.image
  network_id   = hcloud_network.swiss365_net.id
  ssh_key_name = var.ssh_key_name
}

module "workspace_host" {
  source       = "./modules/server_common"
  name         = "workspace_host"
  server_type  = "cpx51"
  image        = var.image
  network_id   = hcloud_network.swiss365_net.id
  ssh_key_name = var.ssh_key_name
}

module "desktop_pool_host" {
  source       = "./modules/server_common"
  name         = "desktop_pool_host"
  server_type  = "ax102"
  image        = var.image
  network_id   = hcloud_network.swiss365_net.id
  ssh_key_name = var.ssh_key_name
}
