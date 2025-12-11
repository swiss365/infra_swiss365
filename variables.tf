# variables.tf - Input variables for Swiss365 infrastructure

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "customer_id" {
  description = "Customer identifier (used for naming resources and DNS)"
  type        = string
}

variable "guacamole_domain" {
  description = "Domain for Guacamole access (e.g., customer.swiss365.cloud)"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key in Hetzner Cloud"
  type        = string
  default     = "swiss365-key"
}

variable "image" {
  description = "OS image for all servers"
  type        = string
  default     = "ubuntu-24.04"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "fsn1"
}

variable "network_zone" {
  description = "Network zone for the private network"
  type        = string
  default     = "eu-central"
}

variable "network_cidr" {
  description = "CIDR for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# SSH Private Key (optional, for internal use)
variable "ssh_private_key" {
  description = "SSH private key for server access (base64 encoded)"
  type        = string
  default     = ""
  sensitive   = true
}

# Server Type Variables - Customer configurable
variable "server_type_control" {
  description = "Server type for Control Node (Guacamole)"
  type        = string
  default     = "cx32"
}

variable "server_type_workspace" {
  description = "Server type for Workspace and Desktop Pool servers"
  type        = string
  default     = "cx32"
}

variable "server_type_services" {
  description = "Server type for service servers (Mailcow, Nextcloud, Keycloak)"
  type        = string
  default     = "cx32"
}
