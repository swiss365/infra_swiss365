# variables.tf - Input variables for Swiss365 Shared Infrastructure Model
# Customer provisioning now only creates a Desktop server
# Mailcow, Nextcloud, Keycloak are SHARED central services

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
  default     = ""
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

# Server Type for Desktop (Gen3 types only: cx33, cx43, cx53)
variable "server_type_desktop" {
  description = "Server type for Desktop Server (cx33, cx43, cx53)"
  type        = string
  default     = "cx33"
}

# Callback URL for installation progress
variable "callback_url" {
  description = "Supabase callback URL for installation progress"
  type        = string
  default     = ""
}

# Legacy variables (kept for backwards compatibility with existing Terraform workspace)
variable "server_type_control" {
  description = "Deprecated - maps to server_type_desktop in shared model"
  type        = string
  default     = "cx33"
}

variable "server_type_workspace" {
  description = "Deprecated - not used in shared infrastructure model"
  type        = string
  default     = "cx33"
}

variable "server_type_services" {
  description = "Deprecated - services are now shared centrally"
  type        = string
  default     = "cx33"
}
