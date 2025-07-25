variable "name" {}
variable "server_type" {}
variable "image" {}
variable "network_id" {}
variable "ssh_key_name" {}

resource "hcloud_server" "this" {
  name        = var.name
  server_type = var.server_type
  image       = var.image
  ssh_keys    = [var.ssh_key_name]
  network {
    network_id = var.network_id
    ip         = "auto"
  }
  user_data = file("${path.module}/cloud_init.yml")
}

output "ipv4" {
  value = hcloud_server.this.ipv4_address
}
