resource "hcloud_firewall" "swiss365_fw" {
  name = "${var.customer_id}-fw"
  labels = {
    customer = var.customer_id
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0"]
  }

  apply_to {
    label_selector = "customer=${var.customer_id}"
  }
}
