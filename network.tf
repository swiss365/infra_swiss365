# network.tf - Network configuration for Swiss365 infrastructure

resource "hcloud_network" "swiss365_net" {
  name     = "${var.customer_id}-network"
  ip_range = var.network_cidr

  labels = {
    customer = var.customer_id
    managed  = "terraform"
  }
}

resource "hcloud_network_subnet" "swiss365_subnet" {
  network_id   = hcloud_network.swiss365_net.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.subnet_cidr
}
