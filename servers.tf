# servers.tf - Customer Desktop Server (Shared Infrastructure Model)
# Only ONE server per customer - Desktop with Guacamole
# All other services (Mailcow, Nextcloud, Keycloak) are SHARED centrally

# Random passwords for desktop server
resource "random_password" "desktop_pw" {
  length  = 24
  special = false
}

resource "random_password" "guac_admin_pw" {
  length  = 24
  special = false
}

resource "random_password" "guac_db_pw" {
  length  = 32
  special = false
}

# Single Desktop Server with Guacamole
# This is the ONLY server provisioned per customer
module "desktop_server" {
  source = "./modules/desktop_guacamole"
  
  name                     = "${var.customer_id}-desktop"
  server_type              = var.server_type_desktop
  location                 = var.location
  image                    = var.image
  network_id               = hcloud_network.swiss365_net.id
  ssh_key_name             = var.ssh_key_name
  root_password            = random_password.desktop_pw.result
  guacamole_admin_password = random_password.guac_admin_pw.result
  guacamole_db_password    = random_password.guac_db_pw.result
  customer_id              = var.customer_id
  callback_url             = var.callback_url
  
  labels = {
    customer = var.customer_id
    managed  = "swiss365"
    role     = "desktop"
  }
  
  depends_on = [hcloud_network_subnet.swiss365_subnet]
}
