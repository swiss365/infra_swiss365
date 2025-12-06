terraform {
  required_version = ">= 1.8"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.44"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

