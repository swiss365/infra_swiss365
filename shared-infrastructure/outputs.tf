# Outputs for shared infrastructure
# These values should be stored in shared_services table

output "mailcow_ip" {
  description = "Mailcow server public IP"
  value       = hcloud_server.mailcow.ipv4_address
}

output "mailcow_server_id" {
  description = "Mailcow server ID"
  value       = hcloud_server.mailcow.id
}

output "mailcow_api_url" {
  description = "Mailcow API URL"
  value       = "https://${var.mailcow_domain}/api/v1"
}

output "mailcow_admin_password" {
  description = "Mailcow admin password"
  value       = random_password.mailcow_admin.result
  sensitive   = true
}

output "nextcloud_ip" {
  description = "Nextcloud server public IP"
  value       = hcloud_server.nextcloud.ipv4_address
}

output "nextcloud_server_id" {
  description = "Nextcloud server ID"
  value       = hcloud_server.nextcloud.id
}

output "nextcloud_api_url" {
  description = "Nextcloud OCS API URL"
  value       = "https://${var.nextcloud_domain}/ocs/v1.php"
}

output "nextcloud_admin_password" {
  description = "Nextcloud admin password"
  value       = random_password.nextcloud_admin.result
  sensitive   = true
}

output "keycloak_ip" {
  description = "Keycloak server public IP"
  value       = hcloud_server.keycloak.ipv4_address
}

output "keycloak_server_id" {
  description = "Keycloak server ID"
  value       = hcloud_server.keycloak.id
}

output "keycloak_api_url" {
  description = "Keycloak Admin API URL"
  value       = "https://${var.keycloak_domain}/admin/realms"
}

output "keycloak_admin_password" {
  description = "Keycloak admin password"
  value       = random_password.keycloak_admin.result
  sensitive   = true
}

output "load_balancer_ip" {
  description = "Shared Load Balancer IP"
  value       = hcloud_load_balancer.shared.ipv4
}

output "network_id" {
  description = "Shared network ID"
  value       = hcloud_network.shared.id
}
