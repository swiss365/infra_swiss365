# Shared Infrastructure - Central Multi-Tenant Services
# Deploy ONCE, serves ALL customers
# Configuration is in versions.tf and variables.tf

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
  network_zone = var.network_zone
  ip_range     = "10.0.1.0/24"
}

# Central Mailcow Server (Multi-Domain)
resource "hcloud_server" "mailcow" {
  name        = "central-mailcow"
  server_type = var.server_type_mailcow
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
    api_key          = random_password.mailcow_db.result
    callback_url     = var.callback_url
    workspace_id     = var.workspace_id
    agent_secret     = var.agent_secret
  })
  
  depends_on = [hcloud_network_subnet.shared]
}

# Central Nextcloud Server (Multi-Tenant)
resource "hcloud_server" "nextcloud" {
  name        = "central-nextcloud"
  server_type = var.server_type_nextcloud
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
    callback_url     = var.callback_url
    workspace_id     = var.workspace_id
    agent_secret     = var.agent_secret
  })
  
  depends_on = [hcloud_network_subnet.shared]
}

# Central Keycloak Server (Multi-Realm)
resource "hcloud_server" "keycloak" {
  name        = "central-keycloak"
  server_type = var.server_type_keycloak
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
    callback_url    = var.callback_url
    workspace_id    = var.workspace_id
    agent_secret    = var.agent_secret
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

# Load Balancer Targets
resource "hcloud_load_balancer_target" "mailcow" {
  load_balancer_id = hcloud_load_balancer.shared.id
  type             = "server"
  server_id        = hcloud_server.mailcow.id
  use_private_ip   = true
}

resource "hcloud_load_balancer_target" "nextcloud" {
  load_balancer_id = hcloud_load_balancer.shared.id
  type             = "server"
  server_id        = hcloud_server.nextcloud.id
  use_private_ip   = true
}

resource "hcloud_load_balancer_target" "keycloak" {
  load_balancer_id = hcloud_load_balancer.shared.id
  type             = "server"
  server_id        = hcloud_server.keycloak.id
  use_private_ip   = true
}

# Load Balancer Services with Health Checks

# Mailcow HTTPS Service (Port 443 -> 443)
resource "hcloud_load_balancer_service" "mailcow_https" {
  load_balancer_id = hcloud_load_balancer.shared.id
  protocol         = "https"
  listen_port      = 443
  destination_port = 443

  http {
    sticky_sessions = true
    certificates    = []  # Add SSL cert IDs when available
  }

  health_check {
    protocol = "http"
    port     = 443
    interval = 15
    timeout  = 10
    retries  = 3

    http {
      domain       = var.mailcow_domain
      path         = "/api/v1/get/status/version"
      status_codes = ["200", "401"]  # 401 = API requires auth, but is responding
    }
  }
}

# Nextcloud HTTPS Service (Port 443 -> 443)
resource "hcloud_load_balancer_service" "nextcloud_https" {
  load_balancer_id = hcloud_load_balancer.shared.id
  protocol         = "https"
  listen_port      = 8443  # Different port to avoid conflict
  destination_port = 443

  http {
    sticky_sessions = true
    certificates    = []
  }

  health_check {
    protocol = "http"
    port     = 443
    interval = 15
    timeout  = 10
    retries  = 3

    http {
      domain       = var.nextcloud_domain
      path         = "/status.php"
      status_codes = ["200"]
    }
  }
}

# Keycloak HTTPS Service (Port 443 -> 80, Keycloak runs on port 80 internally)
resource "hcloud_load_balancer_service" "keycloak_https" {
  load_balancer_id = hcloud_load_balancer.shared.id
  protocol         = "https"
  listen_port      = 9443  # Different port to avoid conflict
  destination_port = 80    # Keycloak runs on port 80 internally (mapped from 8080)

  http {
    sticky_sessions = true
    certificates    = []
  }

  health_check {
    protocol = "http"
    port     = 80           # Health check on port 80 where Keycloak listens
    interval = 15
    timeout  = 10
    retries  = 3

    http {
      domain       = var.keycloak_domain
      path         = "/"    # Keycloak root path returns 200/302
      status_codes = ["200", "302", "303"]  # Keycloak redirects on root
    }
  }
}

# HTTP to HTTPS redirect services
resource "hcloud_load_balancer_service" "http_redirect" {
  load_balancer_id = hcloud_load_balancer.shared.id
  protocol         = "http"
  listen_port      = 80
  destination_port = 80

  health_check {
    protocol = "http"
    port     = 80
    interval = 15
    timeout  = 10
    retries  = 3

    http {
      path         = "/"
      status_codes = ["200", "301", "302", "404"]
    }
  }
}
