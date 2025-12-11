# outputs.tf - Terraform outputs for Swiss365 Shared Infrastructure Model
# Customer Desktop only - shared services are accessed via API

# Desktop Server Information
output "desktop_ip" {
  description = "Public IP of the customer desktop server"
  value       = module.desktop_server.ipv4
}

output "desktop_server_id" {
  description = "Hetzner server ID of the desktop server"
  value       = module.desktop_server.server_id
}

output "desktop_private_ip" {
  description = "Private IP of the desktop server"
  value       = module.desktop_server.private_ip
}

# Guacamole Access
output "guacamole_url" {
  description = "URL to access Guacamole web interface"
  value       = "http://${module.desktop_server.ipv4}:8080/guacamole/"
}

output "guacamole_username" {
  description = "Guacamole admin username"
  value       = "guacadmin"
}

# Credentials (sensitive)
output "desktop_root_password" {
  description = "Root password for desktop server"
  value       = random_password.desktop_pw.result
  sensitive   = true
}

output "guacamole_admin_password" {
  description = "Guacamole admin password"
  value       = random_password.guac_admin_pw.result
  sensitive   = true
}

output "guac_db_password" {
  description = "PostgreSQL database password for Guacamole"
  value       = random_password.guac_db_pw.result
  sensitive   = true
}

# Network Information
output "network_id" {
  description = "Customer network ID"
  value       = hcloud_network.swiss365_net.id
}

output "subnet_id" {
  description = "Customer subnet ID"
  value       = hcloud_network_subnet.swiss365_subnet.id
}

# Customer Domain
output "customer_domain" {
  description = "Customer domain for accessing services"
  value       = "${var.customer_id}.swiss365.cloud"
}

# Architecture Info
output "architecture" {
  description = "Infrastructure architecture type"
  value       = "shared_infrastructure_v2"
}

output "servers_provisioned" {
  description = "Number of servers provisioned for this customer"
  value       = 1
}

# Shared Services Info (pointing to central infrastructure)
output "mail_service" {
  description = "Mail service domain (shared)"
  value       = "mail.swiss365.cloud"
}

output "cloud_service" {
  description = "Cloud storage domain (shared)"
  value       = "cloud.swiss365.cloud"
}

output "auth_service" {
  description = "Authentication service domain (shared)"
  value       = "auth.swiss365.cloud"
}
