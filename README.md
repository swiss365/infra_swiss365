# infra_swiss365

This repository contains a sample Terraform configuration for deploying servers
and a load balancer on Hetzner Cloud. It demonstrates how to use Terraform
modules for common server configuration and load balancer setup. The new
`modules/rollout` module bundles these pieces so the entire stack can be
provisioned with a single module call.

1. Install Terraform 1.8 or newer.
2. Export your Hetzner Cloud API token as `HCLOUD_TOKEN` (or pass it via `-var hcloud_token=...`).
3. Run `terraform init` to download providers and modules.
4. Execute `terraform plan` to review the resources that will be created.
5. Finally run `terraform apply` to provision the virtual machines and load balancer.

## Rollout module

To provision the entire Swiss365 stack in one step you can use the
`modules/rollout` module:

```hcl
module "rollout" {
  source       = "./modules/rollout"
  ssh_key_name = var.ssh_key_name
  image        = var.image
  network_cidr = var.network_cidr
}
```

After applying the module the outputs provide the public IP addresses of the
servers and the load balancer.
