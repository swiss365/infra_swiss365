# Server Common Module - Standard server with RDP access

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

variable "name" {
  description = "Server name"
  type        = string
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx32"
}

variable "image" {
  description = "OS image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "network_id" {
  description = "Network ID to attach"
  type        = number
}

variable "ssh_key_name" {
  description = "SSH key name in Hetzner"
  type        = string
}

variable "root_password" {
  description = "Root password (plaintext)"
  type        = string
  sensitive   = true
}

variable "labels" {
  type    = map(string)
  default = {}
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
    root_password = var.root_password
  })
}

output "ipv4" {
  value = hcloud_server.this.ipv4_address
}

output "server_id" {
  value = hcloud_server.this.id
}
