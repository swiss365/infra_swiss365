# providers.tf - Provider configuration
# NOTE: DNS is managed via Supabase Edge Function (hetzner-dns-manager)
# The hetznerdns provider is NOT used as it's incompatible with Hetzner Cloud DNS

provider "hcloud" {
  token = var.hcloud_token
}

provider "random" {}
