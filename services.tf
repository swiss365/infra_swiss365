# services.tf - Service infrastructure for Swiss365 customers
# Provisions Mailcow, Nextcloud, and Keycloak servers per customer

# Random passwords for services
resource "random_password" "mailcow_api_key" {
  length  = 32
  special = false
}

resource "random_password" "nextcloud_admin_pw" {
  length  = 24
  special = false
}

resource "random_password" "nextcloud_db_pw" {
  length  = 24
  special = false
}

resource "random_password" "keycloak_admin_pw" {
  length  = 24
  special = false
}

resource "random_password" "keycloak_db_pw" {
  length  = 24
  special = false
}

resource "random_password" "mailcow_root_pw" {
  length  = 16
  special = false
}

resource "random_password" "nextcloud_root_pw" {
  length  = 16
  special = false
}

resource "random_password" "keycloak_root_pw" {
  length  = 16
  special = false
}

# Mailcow Server - Email services
module "mailcow_server" {
  source        = "./modules/mailcow"
  name          = "${var.customer_id}-mail"
  server_type   = var.server_type_services
  location      = var.location
  image         = var.image
  network_id    = hcloud_network.swiss365_net.id
  ssh_key_name  = var.ssh_key_name
  root_password = random_password.mailcow_root_pw.result
  
  mail_domain = var.customer_id
  hostname    = "mail.${var.customer_id}.swiss365.cloud"
  api_key     = random_password.mailcow_api_key.result
  
  labels = {
    customer = var.customer_id
    role     = "mailcow"
    service  = "mail"
  }
  
  depends_on = [hcloud_network_subnet.swiss365_subnet]
}

# Nextcloud Server - File storage and collaboration
module "nextcloud_server" {
  source        = "./modules/nextcloud"
  name          = "${var.customer_id}-cloud"
  server_type   = var.server_type_services
  location      = var.location
  image         = var.image
  network_id    = hcloud_network.swiss365_net.id
  ssh_key_name  = var.ssh_key_name
  root_password = random_password.nextcloud_root_pw.result
  
  domain         = "cloud.${var.customer_id}.swiss365.cloud"
  admin_password = random_password.nextcloud_admin_pw.result
  db_password    = random_password.nextcloud_db_pw.result
  
  labels = {
    customer = var.customer_id
    role     = "nextcloud"
    service  = "storage"
  }
  
  depends_on = [hcloud_network_subnet.swiss365_subnet]
}

# Keycloak Server - Identity and Access Management
module "keycloak_server" {
  source        = "./modules/keycloak"
  name          = "${var.customer_id}-auth"
  server_type   = var.server_type_services
  location      = var.location
  image         = var.image
  network_id    = hcloud_network.swiss365_net.id
  ssh_key_name  = var.ssh_key_name
  root_password = random_password.keycloak_root_pw.result
  
  domain         = "auth.${var.customer_id}.swiss365.cloud"
  admin_password = random_password.keycloak_admin_pw.result
  db_password    = random_password.keycloak_db_pw.result
  realm_name     = var.customer_id
  
  labels = {
    customer = var.customer_id
    role     = "keycloak"
    service  = "identity"
  }
  
  depends_on = [hcloud_network_subnet.swiss365_subnet]
}

# Service Outputs
output "mailcow_ip" {
  value = module.mailcow_server.ipv4
}

output "mailcow_api_url" {
  value = module.mailcow_server.api_url
}

output "mailcow_api_key" {
  value     = random_password.mailcow_api_key.result
  sensitive = true
}

output "mailcow_root_password" {
  value     = random_password.mailcow_root_pw.result
  sensitive = true
}

output "nextcloud_ip" {
  value = module.nextcloud_server.ipv4
}

output "nextcloud_url" {
  value = module.nextcloud_server.url
}

output "nextcloud_admin_password" {
  value     = random_password.nextcloud_admin_pw.result
  sensitive = true
}

output "nextcloud_root_password" {
  value     = random_password.nextcloud_root_pw.result
  sensitive = true
}

output "keycloak_ip" {
  value = module.keycloak_server.ipv4
}

output "keycloak_url" {
  value = module.keycloak_server.url
}

output "keycloak_admin_url" {
  value = module.keycloak_server.admin_url
}

output "keycloak_admin_password" {
  value     = random_password.keycloak_admin_pw.result
  sensitive = true
}

output "keycloak_realm" {
  value = module.keycloak_server.realm
}

output "keycloak_root_password" {
  value     = random_password.keycloak_root_pw.result
  sensitive = true
}
