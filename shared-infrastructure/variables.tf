# variables.tf - Input variables for Shared Infrastructure
# Central services that serve ALL customers

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of the SSH key in Hetzner Cloud"
  type        = string
  default     = "swiss365-key"
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

# Domain configuration for central services
variable "mailcow_domain" {
  description = "Domain for central Mailcow mail server"
  type        = string
  default     = "mail.swiss365.cloud"
}

variable "nextcloud_domain" {
  description = "Domain for central Nextcloud storage"
  type        = string
  default     = "cloud.swiss365.cloud"
}

variable "keycloak_domain" {
  description = "Domain for central Keycloak identity provider"
  type        = string
  default     = "auth.swiss365.cloud"
}

# Server types (Gen3 only)
variable "server_type_mailcow" {
  description = "Server type for Mailcow (cx43 recommended for multi-tenant mail)"
  type        = string
  default     = "cx43"
}

variable "server_type_nextcloud" {
  description = "Server type for Nextcloud (cx43 recommended for multi-tenant storage)"
  type        = string
  default     = "cx43"
}

variable "server_type_keycloak" {
  description = "Server type for Keycloak (cx33 sufficient for IAM)"
  type        = string
  default     = "cx33"
}

# Callback URL for installation progress
variable "callback_url" {
  description = "Supabase callback URL for installation progress"
  type        = string
  default     = ""
}

# Supabase configuration for post-deployment registration
variable "supabase_url" {
  description = "Supabase project URL for service registration"
  type        = string
  default     = ""
}

variable "supabase_service_key" {
  description = "Supabase service role key for service registration"
  type        = string
  sensitive   = true
  default     = ""
}

# Agent authentication secret for status server
variable "agent_secret" {
  description = "HMAC secret for authenticating agent commands"
  type        = string
  sensitive   = true
  default     = "swiss365-agent-secret"
}

# Workspace ID for callbacks (empty for shared infrastructure)
variable "workspace_id" {
  description = "Workspace ID for installation callbacks"
  type        = string
  default     = "shared-infrastructure"
}
