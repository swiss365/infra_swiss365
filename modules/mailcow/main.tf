# Mailcow Server Module - Mail server with Docker Compose

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
  default = "cx33"
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

variable "mail_domain" {
  type        = string
  description = "Primary mail domain (e.g., customer.swiss365.cloud)"
}

variable "hostname" {
  type        = string
  description = "Mail server hostname (e.g., mail.customer.swiss365.cloud)"
}

variable "api_key" {
  type        = string
  sensitive   = true
  description = "Mailcow API key for automation"
}

variable "labels" {
  type    = map(string)
  default = {}
}

resource "hcloud_server" "mailcow" {
  name        = var.name
  server_type = var.server_type
  location    = var.location
  image       = var.image
  ssh_keys    = [var.ssh_key_name]
  labels      = var.labels

  user_data = templatefile("${path.module}/cloud_init.yml", {
    root_password = var.root_password
    mail_domain   = var.mail_domain
    hostname      = var.hostname
    api_key       = var.api_key
  })

  network {
    network_id = var.network_id
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

output "ipv4" {
  value = hcloud_server.mailcow.ipv4_address
}

output "server_id" {
  value = hcloud_server.mailcow.id
}

output "api_url" {
  value = "https://${var.hostname}/api/v1"
}

output "api_key" {
  value     = var.api_key
  sensitive = true
}
