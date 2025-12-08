# servers.tf - Server configuration for Swiss365 infrastructure
# Updated to use non-deprecated server types

# Random passwords for all servers
resource "random_password" "control_pw" {
  length  = 16
  special = false
}

resource "random_password" "workspace_pw" {
  length  = 16
  special = false
}

resource "random_password" "desktop_pool_pw" {
  length  = 16
  special = false
}

resource "random_password" "guac_db_pw" {
  length  = 24
  special = false
}

resource "random_password" "guac_admin_pw" {
  length  = 16
  special = false
}

# Workspace Host - Standard server for applications
# Using cx42 (ARM) instead of deprecated cpx51
module "workspace_host" {
  source        = "./modules/server_common"
  name          = "${var.customer_id}-workspace"
  server_type   = "cx42"  # Changed from cpx51 (deprecated)
  image         = var.image
  network_id    = hcloud_network.swiss365_net.id
  ssh_key_name  = var.ssh_key_name
  root_password = random_password.workspace_pw.result
  labels = {
    customer = var.customer_id
    role     = "workspace"
  }
  
  depends_on = [hcloud_network_subnet.swiss365_subnet]
}

# Desktop Pool Host - Standard server for virtual desktops
# Using cx42 (ARM) instead of deprecated cpx51
module "desktop_pool_host" {
  source        = "./modules/server_common"
  name          = "${var.customer_id}-desktop-pool"
  server_type   = "cx42"  # Changed from cpx51 (deprecated)
  image         = var.image
  network_id    = hcloud_network.swiss365_net.id
  ssh_key_name  = var.ssh_key_name
  root_password = random_password.desktop_pool_pw.result
  labels = {
    customer = var.customer_id
    role     = "desktop"
  }
  
  depends_on = [hcloud_network_subnet.swiss365_subnet]
}

# Control Node - Runs Guacamole
# Using cx32 (ARM) - already correct
module "control_node" {
  source        = "./modules/control_node"
  name          = "${var.customer_id}-control"
  server_type   = "cx32"
  image         = var.image
  network_id    = hcloud_network.swiss365_net.id
  ssh_key_name  = var.ssh_key_name
  root_password = random_password.control_pw.result
  
  guac_db_password    = random_password.guac_db_pw.result
  guac_admin_password = random_password.guac_admin_pw.result
  
  workspace_ip       = module.workspace_host.ipv4
  workspace_password = random_password.workspace_pw.result
  desktop_ip         = module.desktop_pool_host.ipv4
  desktop_password   = random_password.desktop_pool_pw.result
  
  labels = {
    customer = var.customer_id
    role     = "control"
  }
  
  depends_on = [
    module.workspace_host,
    module.desktop_pool_host,
    hcloud_network_subnet.swiss365_subnet
  ]
}

output "control_node_password" {
  value     = random_password.control_pw.result
  sensitive = true
}

output "workspace_password" {
  value     = random_password.workspace_pw.result
  sensitive = true
}

output "desktop_pool_password" {
  value     = random_password.desktop_pool_pw.result
  sensitive = true
}
