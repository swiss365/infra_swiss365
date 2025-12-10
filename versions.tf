# versions.tf - Terraform and provider version constraints for Swiss365
# IMPORTANT: No hetznerdns provider - DNS is managed via Edge Function

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

  # Terraform Cloud backend configuration
  cloud {
    organization = "swiss365"

    workspaces {
      tags = ["swiss365"]
    }
  }
}
