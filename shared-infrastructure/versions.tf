# versions.tf - Terraform Cloud configuration for Shared Infrastructure
# This workspace manages the CENTRAL services (Mailcow, Nextcloud, Keycloak)
# Deployed ONCE, serves ALL customers

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Terraform Cloud backend - separate workspace for shared infrastructure
  cloud {
    organization = "swiss365"

    workspaces {
      name = "shared-infrastructure"
    }
  }
}
