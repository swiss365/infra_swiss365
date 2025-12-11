# Load Balancer Module for Guacamole
# Routes traffic to Control Node on port 8080
# Health check path: /guacamole/

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
  description = "Network ID for private networking"
  type        = number
}

variable "domain_name" {
  description = "Domain name for the load balancer"
  type        = string
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "fsn1"
}

variable "labels" {
  type    = map(string)
  default = {}
}

# Load Balancer
resource "hcloud_load_balancer" "this" {
  name               = var.name
  load_balancer_type = "lb11"
  location           = var.location

  labels = merge(var.labels, {
    managed = "terraform"
  })
}

# Attach to private network
resource "hcloud_load_balancer_network" "this" {
  load_balancer_id = hcloud_load_balancer.this.id
  network_id       = var.network_id
}

# Add targets - MUST use private IP for health checks to work
resource "hcloud_load_balancer_target" "this" {
  count            = length(var.target_server_ids)
  type             = "server"
  load_balancer_id = hcloud_load_balancer.this.id
  server_id        = var.target_server_ids[count.index]
  
  # CRITICAL: Use private IP - required for health checks to pass
  use_private_ip = true

  depends_on = [hcloud_load_balancer_network.this]
}

# HTTP Service (port 80 -> 8080)
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
      # CRITICAL: Health check path must be /guacamole/
      path         = "/guacamole/"
      status_codes = ["200", "302", "301"]
    }
  }

  http {
    sticky_sessions = true
    cookie_name     = "GUAC_LB"
    cookie_lifetime = 300
  }
}

# NOTE: HTTPS disabled - requires managed certificate
# To enable HTTPS, add hcloud_managed_certificate resource first

output "ipv4" {
  description = "Public IPv4 address of the load balancer"
  value       = hcloud_load_balancer.this.ipv4
}

output "id" {
  description = "ID of the load balancer"
  value       = hcloud_load_balancer.this.id
}
