# infra_swiss365

This repository contains a sample Terraform configuration for deploying servers
and a load balancer on Hetzner Cloud. It demonstrates how to use Terraform
modules for common server configuration and load balancer setup. The new
`modules/rollout` module bundles these pieces so the entire stack can be
provisioned with a single module call.

1. Install Terraform 1.8 or newer.
2. Export your Hetzner Cloud API token as `TF_VAR_hcloud_token` (or pass it via `-var hcloud_token=...`).
3. Run `terraform init` to download providers and modules.
4. Execute `terraform plan` to review the resources that will be created.
5. Finally run `terraform apply` to provision the virtual machines and load balancer.

Example usage:

```bash
export TF_VAR_hcloud_token=<your-token>
terraform apply -var="customer_id=customerA"
```

The `customer_id` variable is required unless you define it in a `.tfvars` file.

## SSH key handling

Terraform expects only the **name** of an SSH key that already exists in your
Hetzner Cloud project. Upload your public key in the Hetzner Cloud console and
note its name (default: `swiss365_ssh`). Reference this name via the
`ssh_key_name` variable. A minimal `terraform.tfvars` could look like:

```hcl
customer_id  = "customerA"
ssh_key_name = "swiss365_ssh"       # name of the key uploaded at Hetzner
```
You can copy `terraform.tfvars.example` as a starting point for your own
variables file.

Terraform does not need the private key. Instead, store the private key on the
machine that runs Terraform and Ansible. When using Ansible you can point to the
key with `ANSIBLE_PRIVATE_KEY_FILE` or the `--private-key` CLI option.
If you run these tools in a CI system such as "lovable", keep the private key as
a secret variable and provide its path via the environment.

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
