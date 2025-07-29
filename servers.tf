module "control_node" {
  source       = "./modules/server_common"
  name         = "${var.customer_id}-control"
  server_type  = "cpx31"
  image        = var.image
  network_id   = hcloud_network.swiss365_net.id
  ssh_key_name = var.ssh_key_name
}

module "workspace_host" {
  source       = "./modules/server_common"
  name         = "${var.customer_id}-workspace"
  server_type  = "cpx51"
  image        = var.image
  network_id   = hcloud_network.swiss365_net.id
  ssh_key_name = var.ssh_key_name
}

module "desktop_pool_host" {
  source       = "./modules/server_common"
  name         = "${var.customer_id}-desktop-pool"
  server_type  = "ccx63"
  image        = var.image
  network_id   = hcloud_network.swiss365_net.id
  ssh_key_name = var.ssh_key_name
}
