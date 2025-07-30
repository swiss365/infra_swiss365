output "control_public_ip" {
  value = module.control_node.ipv4
}

output "workspace_public_ip" {
  value = module.workspace_host.ipv4
}

output "desktop_pool_public_ip" {
  value = module.desktop_pool_host.ipv4
}

output "guac_lb_ip" {
  value = module.guac_lb.ipv4
}

output "control_root_password" {
  value     = random_password.control_pw.result
  sensitive = true
}

output "workspace_root_password" {
  value     = random_password.workspace_pw.result
  sensitive = true
}

output "desktop_pool_root_password" {
  value     = random_password.desktop_pool_pw.result
  sensitive = true
}
