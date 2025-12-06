terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

variable "name" {}
variable "server_type" {}
variable "image" {}
variable "network_id" {}
variable "ssh_key_name" {}
variable "root_password_hash" {}
variable "labels" {
  type    = map(string)
  default = {}
}
variable "extra_cloud_init" {
  description = "Additional cloud-init runcmd script"
  type        = string
  default     = ""
}

resource "hcloud_server" "this" {
  name        = var.name
  server_type = var.server_type
  image       = var.image
  ssh_keys    = [var.ssh_key_name]
  network {
    network_id = var.network_id
    ip         = "auto"
  }
  labels = var.labels
  user_data = templatefile("${path.module}/cloud_init.yml", {
    root_password_hash = var.root_password_hash
    extra_cloud_init   = var.extra_cloud_init
  })
}

output "ipv4" {
  value = hcloud_server.this.ipv4_address
}

output "server_id" {
  value = hcloud_server.this.id
}
