# network.tf - Network configuration for Swiss365 infrastructure

resource "hcloud_network" "swiss365_net" {
  name     = "${var.customer_id}-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "swiss365_subnet" {
  network_id   = hcloud_network.swiss365_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
