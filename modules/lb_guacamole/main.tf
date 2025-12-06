# modules/lb_guacamole/main.tf

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

variable "name" {
  type        = string
  description = "Name of the load balancer"
}

variable "target_server_ids" {
  type        = list(number)
  description = "List of server IDs to add as targets"
}

variable "network_id" {
  type        = number
  description = "Network ID for the load balancer"
}

variable "domain_name" {
  type        = string
  description = "Domain name for SSL certificate"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels to apply to resources"
}

# Load Balancer
resource "hcloud_load_balancer" "this" {
  name               = var.name
  load_balancer_type = "lb11"
  location           = "nbg1"
  labels             = var.labels
}

# Attach to private network
resource "hcloud_load_balancer_network" "this" {
  load_balancer_id = hcloud_load_balancer.this.id
  network_id       = var.network_id
  ip               = "10.20.1.200"
}

# Add targets with PRIVATE IP
resource "hcloud_load_balancer_target" "servers" {
  count            = length(var.target_server_ids)
  type             = "server"
  load_balancer_id = hcloud_load_balancer.this.id
  server_id        = var.target_server_ids[count.index]
  use_private_ip   = true  # WICHTIG: Private IP verwenden!
  
  depends_on = [hcloud_load_balancer_network.this]
}

# Managed SSL Certificate
resource "hcloud_managed_certificate" "this" {
  name         = "${var.name}-cert"
  domain_names = [var.domain_name]
  labels       = var.labels
}

# HTTP Service (Port 80 -> 8080)
resource "hcloud_load_balancer_service" "http" {
  load_balancer_id = hcloud_load_balancer.this.id
  protocol         = "http"
  listen_port      = 80
  destination_port = 8080

  health_check {
    protocol = "http"
    port     = 8080
    interval = 15
    timeout  = 10
    retries  = 3
    http {
      path         = "/guacamole/"  # WICHTIG: Korrekter Pfad!
      status_codes = ["2??", "3??"]
    }
  }
}

# HTTPS Service (Port 443 -> 8080)
resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.this.id
  protocol         = "https"
  listen_port      = 443
  destination_port = 8080

  http {
    certificates = [hcloud_managed_certificate.this.id]
  }

  health_check {
    protocol = "http"
    port     = 8080
    interval = 15
    timeout  = 10
    retries  = 3
    http {
      path         = "/guacamole/"  # WICHTIG: Korrekter Pfad!
      status_codes = ["2??", "3??"]
    }
  }
}

# Outputs
output "ipv4" {
  value = hcloud_load_balancer.this.ipv4
}

output "ipv6" {
  value = hcloud_load_balancer.this.ipv6
}

output "id" {
  value = hcloud_load_balancer.this.id
}
