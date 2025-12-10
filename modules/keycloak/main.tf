# Keycloak Module - Identity and Access Management

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
  description = "Keycloak domain (e.g., auth.customer.swiss365.cloud)"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "realm_name" {
  type        = string
  default     = "swiss365"
  description = "Default realm name"
}

variable "labels" {
  type    = map(string)
  default = {}
}

resource "hcloud_server" "keycloak" {
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
    realm_name     = var.realm_name
  })

  network {
    network_id = var.network_id
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

output "ipv4" {
  value = hcloud_server.keycloak.ipv4_address
}

output "server_id" {
  value = hcloud_server.keycloak.id
}

output "url" {
  value = "https://${var.domain}"
}

output "admin_url" {
  value = "https://${var.domain}/admin"
}

output "admin_user" {
  value = "admin"
}

output "admin_password" {
  value     = var.admin_password
  sensitive = true
}

output "realm" {
  value = var.realm_name
}
