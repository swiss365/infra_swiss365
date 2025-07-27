# infra_swiss365

This repository contains a sample Terraform configuration for deploying servers and load balancer on Hetzner Cloud. It demonstrates how to use Terraform modules for common server configuration and load balancer setup.

Run `terraform init` to download providers and modules, then `terraform plan` to review the resources.

The Hetzner provider requires the API token. Set it using an environment variable
or a `terraform.tfvars` file:

```bash
export TF_VAR_hcloud_token="<your token>"
terraform init
terraform plan
```

The example modules assume the token is supplied via the variable `hcloud_token`.
