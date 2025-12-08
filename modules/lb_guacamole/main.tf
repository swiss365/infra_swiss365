# Load Balancer Module for Guacamole

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

variable "name" {
  description = "Load balancer name"
  type        = string
}

variable "target_server_ids" {
  description = "List of server IDs to target"
  type        = list(number)
}

variable "network_id" {
  description = "Network ID to attach"
  type        = number
}

variable "domain_name" {
  description = "Domain name for the load balancer"
  type        = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

resource "hcloud_load_balancer" "this" {
  name               = var.name
  load_balancer_type = "lb11"
  location           = "nbg1"
  labels             = var.labels
}

resource "hcloud_load_balancer_network" "this" {
  load_balancer_id = hcloud_load_balancer.this.id
  network_id       = var.network_id
}

resource "hcloud_load_balancer_target" "servers" {
  count            = length(var.target_server_ids)
  type             = "server"
  load_balancer_id = hcloud_load_balancer.this.id
  server_id        = var.target_server_ids[count.index]
  use_private_ip   = true  # CRITICAL: Use private network for communication
  
  depends_on = [hcloud_load_balancer_network.this]
}

# HTTP Service (port 80) - redirects to Guacamole
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
      path         = "/guacamole/"
      status_codes = ["200", "302"]
    }
  }
}

# HTTPS Service (port 443) - for production with TLS
resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.this.id
  protocol         = "https"
  listen_port      = 443
  destination_port = 8080

  health_check {
    protocol = "http"
    port     = 8080
    interval = 15
    timeout  = 10
    retries  = 3

    http {
      path         = "/guacamole/"
      status_codes = ["200", "302"]
    }
  }

  # Note: You'll need to add a managed certificate separately
  # or use hcloud_managed_certificate resource
}

output "ipv4" {
  value = hcloud_load_balancer.this.ipv4
}

output "id" {
  value = hcloud_load_balancer.this.id
}
