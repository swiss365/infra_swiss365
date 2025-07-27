terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

variable "name" {}
variable "target_server_ids" {
  type = list(number)
}
variable "network_id" {}

resource "hcloud_load_balancer" "lb" {
  name               = var.name
  load_balancer_type = "lb11"
  location           = "fsn1"
}

resource "hcloud_load_balancer_network" "net" {
  load_balancer_id = hcloud_load_balancer.lb.id
  network_id       = var.network_id
  ip               = "10.20.1.200"
}

resource "hcloud_load_balancer_target" "targets" {
  count            = length(var.target_server_ids)
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = var.target_server_ids[count.index]
}

output "ipv4" {
  value = hcloud_load_balancer.lb.ipv4
}
