module "control_node" {
  source       = "./modules/server_common"
  name         = "${var.customer_id}-control"
  server_type  = "cpx31"
  image        = var.image
  network_id   = hcloud_network.swiss365_net.id
  ssh_key_name = var.ssh_key_name
  labels = {
    customer = var.customer_id
  }
}

module "workspace_host" {
  source       = "./modules/server_common"
  name         = "${var.customer_id}-workspace"
  server_type  = "cpx51"
  image        = var.image
  network_id   = hcloud_network.swiss365_net.id
  ssh_key_name = var.ssh_key_name
  labels = {
    customer = var.customer_id
  }
}

module "desktop_pool_host" {
  source       = "./modules/server_common"
  name         = "${var.customer_id}-desktop-pool"
  server_type  = "cpx51"
  image        = var.image
  network_id   = hcloud_network.swiss365_net.id
  ssh_key_name = var.ssh_key_name
  labels = {
    customer = var.customer_id
  }
}
