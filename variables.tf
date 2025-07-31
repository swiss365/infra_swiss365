variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "customer_id" {
  description = "Unique identifier to prefix all resource names"
  type        = string
}

variable "ssh_key_name" {
  type    = string
  default = "swiss365_ssh"
}

variable "image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "network_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "guacamole_domain" {
  description = "Domain name for the Guacamole endpoint. Typically '<customer_id>.swiss365.cloud' and must exist in Hetzner DNS."
  type        = string
}
