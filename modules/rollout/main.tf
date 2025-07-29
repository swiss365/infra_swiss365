terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

variable "ssh_key_name" {
  type = string
}

variable "customer_id" {
  description = "Prefix for naming resources"
  type        = string
}

variable "image" {
  type = string
}

variable "network_cidr" {
  type = string
}

# Network
resource "hcloud_network" "net" {
  name     = "${var.customer_id}-network"
  ip_range = var.network_cidr
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.20.1.0/24"
}

# Servers
module "control_node" {
  source       = "../server_common"
  name         = "${var.customer_id}-control"
  server_type  = "ccx63"
  image        = var.image
  network_id   = hcloud_network.net.id
  ssh_key_name = var.ssh_key_name
}

module "workspace_host" {
  source       = "../server_common"
  name         = "${var.customer_id}-workspace"
  server_type  = "cpx51"
  image        = var.image
  network_id   = hcloud_network.net.id
  ssh_key_name = var.ssh_key_name
}

module "desktop_pool_host" {
  source       = "../server_common"
  name         = "${var.customer_id}-desktop-pool"
  server_type  = "ccx63"
  image        = var.image
  network_id   = hcloud_network.net.id
  ssh_key_name = var.ssh_key_name
}

# Load balancer for Guacamole
module "guac_lb" {
  source            = "../lb_guacamole"
  name              = "${var.customer_id}-guacamole-lb"
  target_server_ids = [module.desktop_pool_host.server_id]
  network_id        = hcloud_network.net.id
}

output "control_public_ip" {
  value = module.control_node.ipv4
}

output "workspace_public_ip" {
  value = module.workspace_host.ipv4
}

output "desktop_pool_public_ip" {
  value = module.desktop_pool_host.ipv4
}

output "guac_lb_ip" {
  value = module.guac_lb.ipv4
}

output "network_id" {
  value = hcloud_network.net.id
}
