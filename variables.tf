# variables.tf - Input variables for Swiss365 infrastructure

variable "customer_id" {
  description = "Unique customer identifier"
  type        = string
}

variable "image" {
  description = "OS image for servers"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_key_name" {
  description = "Name of SSH key in Hetzner Cloud"
  type        = string
}

variable "guacamole_domain" {
  description = "Domain for Guacamole access (e.g., customer.swiss365.cloud)"
  type        = string
}

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}
