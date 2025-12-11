# Desktop + Guacamole Combined Module
# Single server per customer with RDP desktop and Guacamole web access

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

variable "name" {
  description = "Server name (customer_id-desktop)"
  type        = string
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx33"
}

variable "image" {
  description = "OS image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "fsn1"
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

variable "guacamole_admin_password" {
  description = "Guacamole admin password"
  type        = string
  sensitive   = true
}

variable "guacamole_db_password" {
  description = "Guacamole PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "customer_id" {
  description = "Customer identifier for domain"
  type        = string
}

variable "callback_url" {
  description = "Supabase callback URL for installation progress"
  type        = string
  default     = ""
}

variable "labels" {
  type    = map(string)
  default = {}
}

resource "hcloud_server" "desktop" {
  name        = var.name
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys    = [var.ssh_key_name]
  
  network {
    network_id = var.network_id
  }
  
  labels = merge(var.labels, {
    role        = "desktop"
    customer_id = var.customer_id
  })
  
  user_data = templatefile("${path.module}/cloud_init.yml", {
    root_password            = var.root_password
    guacamole_admin_password = var.guacamole_admin_password
    guacamole_db_password    = var.guacamole_db_password
    customer_id              = var.customer_id
    callback_url             = var.callback_url
  })
}

output "ipv4" {
  value = hcloud_server.desktop.ipv4_address
}

output "private_ip" {
  value = hcloud_server.desktop.network[*].ip
}

output "server_id" {
  value = hcloud_server.desktop.id
}

output "root_password" {
  value     = var.root_password
  sensitive = true
}

output "guacamole_admin_password" {
  value     = var.guacamole_admin_password
  sensitive = true
}
