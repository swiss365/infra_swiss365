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
   A firewall is created automatically and attached to all servers based on a
   common `customer` label.

Example usage:

```bash
export TF_VAR_hcloud_token=<your-token>
terraform apply -var="customer_id=customerA"
```

The `customer_id` variable is required unless you define it in a `.tfvars` file.
All resources receive a `customer` label derived from this value so the firewall
rules apply automatically.

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

Random root passwords are generated automatically for all VMs. You can
retrieve them from the Terraform outputs after `apply`:

```bash
terraform output control_root_password
terraform output workspace_root_password
terraform output desktop_pool_root_password
```

## Connecting to the servers

Retrieve the IP addresses with `terraform output` and connect via SSH using the
key referenced in `ssh_key_name` (default: `swiss365_ssh`):

```bash
terraform output
ssh -i /path/to/private_key root@$(terraform output -raw control_public_ip)
ssh -i /path/to/private_key root@$(terraform output -raw workspace_public_ip)
ssh -i /path/to/private_key root@$(terraform output -raw desktop_pool_public_ip)
```

The load balancer listens on port 443 at the address from `guac_lb_ip`. A minimal
cloud-init script installs basic utilities, while the provided Ansible playbook
performs the role-specific setup across all hosts.

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

## Deleting a workspace

To remove all resources for a customer you can use the `destroy.yml` workflow. Trigger it manually in GitHub Actions and provide the Terraform workspace name and the associated `customer_id`. The workflow requires the Hetzner API token stored as the `HCLOUD_TOKEN` secret.

## Example Ansible playbook

After provisioning the servers you can automate the operating system setup via
Ansible. The playbook in `ansible/site.yml` configures each host based on its
role:

- **control** – installs Docker for Proxmox/Docker management
- **workspace** – installs Wine for application hosting
- **desktop_pool** – installs `xrdp` for virtual desktop access
- **guac_lb** – installs Nginx and deploys a simple reverse proxy configuration
  for the Guacamole load balancer

Run the playbook from the `ansible` directory using the same SSH key that was
uploaded to Hetzner Cloud:

```bash
cd ansible
ansible-playbook site.yml -u root --private-key /path/to/private_key
```

Adjust `ansible/inventory.yml` if the IP addresses differ from the Terraform
outputs. Any service credentials generated during the playbook run (for example
Docker registry passwords) should be captured from the Ansible output and stored
securely for each customer.

