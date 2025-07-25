resource "hcloud_network" "swiss365_net" {
  name     = "swiss365_network"
  ip_range = var.network_cidr
}

resource "hcloud_network_subnet" "swiss365_subnet" {
  network_id   = hcloud_network.swiss365_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.20.1.0/24"
}
