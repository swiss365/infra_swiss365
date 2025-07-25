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
  value = module.guac_lb.hcloud_load_balancer.lb.ipv4
}
