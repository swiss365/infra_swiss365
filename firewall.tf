resource "hcloud_firewall" "main" {
  name = "${var.customer_id}_fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  apply_to {
    server = module.control_node.server_id
  }

  apply_to {
    server = module.workspace_host.server_id
  }

  apply_to {
    server = module.desktop_pool_host.server_id
  }
}
