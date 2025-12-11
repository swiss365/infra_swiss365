# Shared Infrastructure - Central Multi-Tenant Services
# Deploy ONCE, serves ALL customers

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "SSH key name in Hetzner"
  type        = string
  default     = "swiss365-key"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "fsn1"
}

variable "mailcow_domain" {
  description = "Domain for central Mailcow"
  type        = string
  default     = "mail.swiss365.cloud"
}

variable "nextcloud_domain" {
  description = "Domain for central Nextcloud"
  type        = string
  default     = "cloud.swiss365.cloud"
}

variable "keycloak_domain" {
  description = "Domain for central Keycloak"
  type        = string
  default     = "auth.swiss365.cloud"
}

provider "hcloud" {
  token = var.hcloud_token
}

# Random passwords for services
resource "random_password" "mailcow_admin" {
  length  = 24
  special = false
}

resource "random_password" "nextcloud_admin" {
  length  = 24
  special = false
}

resource "random_password" "keycloak_admin" {
  length  = 24
  special = false
}

resource "random_password" "mailcow_db" {
  length  = 32
  special = false
}

resource "random_password" "nextcloud_db" {
  length  = 32
  special = false
}

resource "random_password" "keycloak_db" {
  length  = 32
  special = false
}

# Shared network for central services
resource "hcloud_network" "shared" {
  name     = "shared-services-net"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "shared" {
  network_id   = hcloud_network.shared.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Central Mailcow Server (Multi-Domain)
resource "hcloud_server" "mailcow" {
  name        = "central-mailcow"
  server_type = "cx43"  # 8 vCPU, 16GB RAM for multi-tenant mail
  image       = "ubuntu-24.04"
  location    = var.location
  ssh_keys    = [var.ssh_key_name]
  
  network {
    network_id = hcloud_network.shared.id
    ip         = "10.0.1.10"
  }
  
  labels = {
    role    = "mailcow"
    service = "shared"
  }
  
  user_data = templatefile("${path.module}/cloud_init_mailcow.yml", {
    mailcow_domain   = var.mailcow_domain
    db_password      = random_password.mailcow_db.result
    admin_password   = random_password.mailcow_admin.result
  })
  
  depends_on = [hcloud_network_subnet.shared]
}

# Central Nextcloud Server (Multi-Tenant)
resource "hcloud_server" "nextcloud" {
  name        = "central-nextcloud"
  server_type = "cx43"  # 8 vCPU, 16GB RAM for multi-tenant storage
  image       = "ubuntu-24.04"
  location    = var.location
  ssh_keys    = [var.ssh_key_name]
  
  network {
    network_id = hcloud_network.shared.id
    ip         = "10.0.1.20"
  }
  
  labels = {
    role    = "nextcloud"
    service = "shared"
  }
  
  user_data = templatefile("${path.module}/cloud_init_nextcloud.yml", {
    nextcloud_domain = var.nextcloud_domain
    db_password      = random_password.nextcloud_db.result
    admin_password   = random_password.nextcloud_admin.result
  })
  
  depends_on = [hcloud_network_subnet.shared]
}

# Central Keycloak Server (Multi-Realm)
resource "hcloud_server" "keycloak" {
  name        = "central-keycloak"
  server_type = "cx33"  # 4 vCPU, 8GB RAM for IAM
  image       = "ubuntu-24.04"
  location    = var.location
  ssh_keys    = [var.ssh_key_name]
  
  network {
    network_id = hcloud_network.shared.id
    ip         = "10.0.1.30"
  }
  
  labels = {
    role    = "keycloak"
    service = "shared"
  }
  
  user_data = templatefile("${path.module}/cloud_init_keycloak.yml", {
    keycloak_domain = var.keycloak_domain
    db_password     = random_password.keycloak_db.result
    admin_password  = random_password.keycloak_admin.result
  })
  
  depends_on = [hcloud_network_subnet.shared]
}

# Load Balancer for central services
resource "hcloud_load_balancer" "shared" {
  name               = "shared-services-lb"
  load_balancer_type = "lb11"
  location           = var.location
}

resource "hcloud_load_balancer_network" "shared" {
  load_balancer_id = hcloud_load_balancer.shared.id
  network_id       = hcloud_network.shared.id
  ip               = "10.0.1.2"
}

# Mailcow target (HTTPS)
resource "hcloud_load_balancer_target" "mailcow" {
  load_balancer_id = hcloud_load_balancer.shared.id
  type             = "server"
  server_id        = hcloud_server.mailcow.id
  use_private_ip   = true
}

# Nextcloud target
resource "hcloud_load_balancer_target" "nextcloud" {
  load_balancer_id = hcloud_load_balancer.shared.id
  type             = "server"
  server_id        = hcloud_server.nextcloud.id
  use_private_ip   = true
}

# Keycloak target
resource "hcloud_load_balancer_target" "keycloak" {
  load_balancer_id = hcloud_load_balancer.shared.id
  type             = "server"
  server_id        = hcloud_server.keycloak.id
  use_private_ip   = true
}
