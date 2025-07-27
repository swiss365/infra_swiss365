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

variable "image" {
  type = string
}

variable "network_cidr" {
  type = string
}

# Network
resource "hcloud_network" "net" {
  name     = "swiss365_network"
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
  name         = "control_node"
  server_type  = "cpx31"
  image        = var.image
  network_id   = hcloud_network.net.id
  ssh_key_name = var.ssh_key_name
}

module "workspace_host" {
  source       = "../server_common"
  name         = "workspace_host"
  server_type  = "cpx51"
  image        = var.image
  network_id   = hcloud_network.net.id
  ssh_key_name = var.ssh_key_name
}

module "desktop_pool_host" {
  source       = "../server_common"
  name         = "desktop_pool_host"
  server_type  = "ax102"
  image        = var.image
  network_id   = hcloud_network.net.id
  ssh_key_name = var.ssh_key_name
}

# Load balancer for Guacamole
module "guac_lb" {
  source            = "../lb_guacamole"
  name              = "guacamole_lb"
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
