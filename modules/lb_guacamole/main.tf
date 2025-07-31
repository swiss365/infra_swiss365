terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
    }
  }
}

variable "name" {}
variable "target_server_ids" {
  type = list(number)
}
variable "network_id" {}
variable "domain_name" {}

locals {
  domain_parts = split(".", var.domain_name)
  zone_name    = join(".", slice(local.domain_parts, 1, length(local.domain_parts)))
  record_name  = local.domain_parts[0]
}
variable "labels" {
  type    = map(string)
  default = {}
}

resource "hcloud_load_balancer" "lb" {
  name               = var.name
  load_balancer_type = "lb11"
  location           = "fsn1"
  labels             = var.labels
}

resource "hcloud_managed_certificate" "cert" {
  name         = "${var.name}-cert"
  domain_names = [var.domain_name]
}

resource "hcloud_load_balancer_network" "net" {
  load_balancer_id = hcloud_load_balancer.lb.id
  network_id       = var.network_id
  ip               = "10.20.1.200"
}

data "hetznerdns_zone" "this" {
  name = local.zone_name
}

resource "hetznerdns_record" "a_record" {
  zone_id = data.hetznerdns_zone.this.id
  name    = local.record_name
  type    = "A"
  value   = hcloud_load_balancer.lb.ipv4
  ttl     = 300
}

resource "hcloud_load_balancer_target" "targets" {
  count            = length(var.target_server_ids)
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = var.target_server_ids[count.index]
}

resource "hcloud_load_balancer_service" "http" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "http"
  listen_port      = 80
  destination_port = 8080
}

resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "https"
  listen_port      = 443
  destination_port = 8080
  http {
    certificates = [hcloud_managed_certificate.cert.id]
  }
}

output "ipv4" {
  value = hcloud_load_balancer.lb.ipv4
}
