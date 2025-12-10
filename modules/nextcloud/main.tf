# Nextcloud Module - File storage and collaboration

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

variable "name" {
  type = string
}

variable "server_type" {
  type    = string
  default = "cx32"
}

variable "location" {
  type    = string
  default = "fsn1"
}

variable "image" {
  type    = string
  default = "ubuntu-22.04"
}

variable "network_id" {
  type = number
}

variable "ssh_key_name" {
  type = string
}

variable "root_password" {
  type      = string
  sensitive = true
}

variable "domain" {
  type        = string
  description = "Nextcloud domain (e.g., cloud.customer.swiss365.cloud)"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "labels" {
  type    = map(string)
  default = {}
}

resource "hcloud_server" "nextcloud" {
  name        = var.name
  server_type = var.server_type
  location    = var.location
  image       = var.image
  ssh_keys    = [var.ssh_key_name]
  labels      = var.labels

  user_data = templatefile("${path.module}/cloud_init.yml", {
    root_password  = var.root_password
    domain         = var.domain
    admin_password = var.admin_password
    db_password    = var.db_password
  })

  network {
    network_id = var.network_id
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

output "ipv4" {
  value = hcloud_server.nextcloud.ipv4_address
}

output "server_id" {
  value = hcloud_server.nextcloud.id
}

output "url" {
  value = "https://${var.domain}"
}

output "admin_user" {
  value = "admin"
}

output "admin_password" {
  value     = var.admin_password
  sensitive = true
}

output "db_password" {
  value     = var.db_password
  sensitive = true
}
