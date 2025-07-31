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
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = ">= 2.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "hetznerdns" {
  apitoken = var.hetznerdns_token
}
