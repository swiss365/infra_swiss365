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
