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
  customer_id  = var.customer_id
  ssh_key_name = var.ssh_key_name
  image        = var.image
  network_cidr = var.network_cidr
}
```

After applying the module the outputs provide the public IP addresses of the
servers and the load balancer.

Every deployment also creates a dedicated firewall named with the `customer_id`
prefix. The firewall is automatically attached to all servers so that each
customer's traffic is isolated.

## Multi-customer usage

Use the `customer_id` variable to prefix all resource names. Create a separate
Terraform workspace for each customer so their state files remain isolated:

```bash
terraform workspace new customerA
terraform workspace select customerA
terraform apply -var="customer_id=customerA"
```

You can also configure a remote backend (e.g. S3 or Terraform Cloud) and use a
different state path per workspace for better scalability.
