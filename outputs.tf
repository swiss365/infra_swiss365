# outputs.tf - Terraform outputs for Swiss365 infrastructure

output "control_public_ip" {
  description = "Public IP of the control node (Guacamole server)"
  value       = module.control_node.ipv4
}

output "workspace_public_ip" {
  description = "Public IP of the workspace server"
  value       = module.workspace_host.ipv4
}

output "desktop_pool_public_ip" {
  description = "Public IP of the desktop pool server"
  value       = module.desktop_pool_host.ipv4
}

output "guac_lb_ip" {
  description = "Public IP of the Guacamole load balancer"
  value       = module.guac_lb.ipv4
}

output "control_root_password" {
  description = "Root password for control node"
  value       = random_password.control_pw.result
  sensitive   = true
}

output "workspace_root_password" {
  description = "Root password for workspace server"
  value       = random_password.workspace_pw.result
  sensitive   = true
}

output "desktop_pool_root_password" {
  description = "Root password for desktop pool server"
  value       = random_password.desktop_pool_pw.result
  sensitive   = true
}

output "guacamole_url" {
  description = "URL to access Guacamole"
  value       = "https://${var.guacamole_domain}/guacamole"
}

output "guacamole_username" {
  description = "Guacamole admin username"
  value       = "guacadmin"
}

output "guacamole_password" {
  description = "Guacamole admin password (default, change after first login)"
  value       = "guacadmin"
  sensitive   = true
}

output "guac_db_password" {
  description = "PostgreSQL database password for Guacamole"
  value       = random_password.guac_db_pw.result
  sensitive   = true
}

# Service Infrastructure Outputs
output "mailcow_ip" {
  description = "Public IP of the Mailcow server"
  value       = module.mailcow_server.ipv4
}

output "mailcow_api_url" {
  description = "Mailcow API URL"
  value       = module.mailcow_server.api_url
}

output "mailcow_api_key" {
  description = "Mailcow API key"
  value       = module.mailcow_server.api_key
  sensitive   = true
}

output "mailcow_root_password" {
  description = "Root password for Mailcow server"
  value       = random_password.mailcow_root_pw.result
  sensitive   = true
}

output "nextcloud_ip" {
  description = "Public IP of the Nextcloud server"
  value       = module.nextcloud_server.ipv4
}

output "nextcloud_url" {
  description = "Nextcloud URL"
  value       = module.nextcloud_server.url
}

output "nextcloud_admin_password" {
  description = "Nextcloud admin password"
  value       = module.nextcloud_server.admin_password
  sensitive   = true
}

output "nextcloud_root_password" {
  description = "Root password for Nextcloud server"
  value       = random_password.nextcloud_root_pw.result
  sensitive   = true
}

output "keycloak_ip" {
  description = "Public IP of the Keycloak server"
  value       = module.keycloak_server.ipv4
}

output "keycloak_url" {
  description = "Keycloak URL"
  value       = module.keycloak_server.url
}

output "keycloak_admin_url" {
  description = "Keycloak admin URL"
  value       = module.keycloak_server.admin_url
}

output "keycloak_admin_password" {
  description = "Keycloak admin password"
  value       = module.keycloak_server.admin_password
  sensitive   = true
}

output "keycloak_realm" {
  description = "Default Keycloak realm"
  value       = module.keycloak_server.realm
}

output "keycloak_root_password" {
  description = "Root password for Keycloak server"
  value       = random_password.keycloak_root_pw.result
  sensitive   = true
}
