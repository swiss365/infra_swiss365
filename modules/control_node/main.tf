# Control Node Module - Deploys Guacamole via Cloud-Init
# This module creates the control node server with full Guacamole installation

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
  default     = "cpx31"
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

variable "root_password_hash" {
  description = "Hashed root password"
  type        = string
  sensitive   = true
}

variable "guac_db_password" {
  description = "PostgreSQL password for Guacamole"
  type        = string
  sensitive   = true
}

variable "guac_admin_password" {
  description = "Guacamole admin password"
  type        = string
  sensitive   = true
}

variable "workspace_ip" {
  description = "IP address of workspace server"
  type        = string
  default     = ""
}

variable "workspace_password" {
  description = "Root password of workspace server"
  type        = string
  sensitive   = true
  default     = ""
}

variable "desktop_ip" {
  description = "IP address of desktop pool server"
  type        = string
  default     = ""
}

variable "desktop_password" {
  description = "Root password of desktop pool server"
  type        = string
  sensitive   = true
  default     = ""
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
    root_password_hash  = var.root_password_hash
    guac_db_password    = var.guac_db_password
    guac_admin_password = var.guac_admin_password
    workspace_ip        = var.workspace_ip
    workspace_password  = var.workspace_password
    desktop_ip          = var.desktop_ip
    desktop_password    = var.desktop_password
  })
}

output "ipv4" {
  value = hcloud_server.this.ipv4_address
}

output "server_id" {
  value = hcloud_server.this.id
}
