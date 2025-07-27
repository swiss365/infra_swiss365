# infra_swiss365

This repository contains a sample Terraform configuration for deploying servers and load balancer on Hetzner Cloud. It demonstrates how to use Terraform modules for common server configuration and load balancer setup.

1. Install Terraform 1.8 or newer.
2. Export your Hetzner Cloud API token as `HCLOUD_TOKEN` (or pass it via `-var hcloud_token=...`).
3. Run `terraform init` to download providers and modules.
4. Execute `terraform plan` to review the resources that will be created.
5. Finally run `terraform apply` to provision the virtual machines and load balancer.
