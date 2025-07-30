resource "random_password" "control_pw" {
  length  = 16
  special = false
}

module "control_node" {
  source             = "./modules/server_common"
  name               = "${var.customer_id}-control"
  server_type        = "cpx31"
  image              = var.image
  network_id         = hcloud_network.swiss365_net.id
  ssh_key_name       = var.ssh_key_name
  root_password_hash = bcrypt(random_password.control_pw.result)
  labels = {
    customer = var.customer_id
  }
}

resource "random_password" "workspace_pw" {
  length  = 16
  special = false
}

module "workspace_host" {
  source             = "./modules/server_common"
  name               = "${var.customer_id}-workspace"
  server_type        = "cpx51"
  image              = var.image
  network_id         = hcloud_network.swiss365_net.id
  ssh_key_name       = var.ssh_key_name
  root_password_hash = bcrypt(random_password.workspace_pw.result)
  labels = {
    customer = var.customer_id
  }
}

resource "random_password" "desktop_pool_pw" {
  length  = 16
  special = false
}

module "desktop_pool_host" {
  source             = "./modules/server_common"
  name               = "${var.customer_id}-desktop-pool"
  server_type        = "cpx51"
  image              = var.image
  network_id         = hcloud_network.swiss365_net.id
  ssh_key_name       = var.ssh_key_name
  root_password_hash = bcrypt(random_password.desktop_pool_pw.result)
  labels = {
    customer = var.customer_id
  }
}
