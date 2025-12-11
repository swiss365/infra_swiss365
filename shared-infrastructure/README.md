# Swiss365 Shared Infrastructure

## Overview

This Terraform configuration deploys the **central shared services** for Swiss365:

- **Mailcow** - Multi-tenant email server (mail.swiss365.cloud)
- **Nextcloud** - Multi-tenant file storage (cloud.swiss365.cloud)  
- **Keycloak** - Multi-tenant identity provider (auth.swiss365.cloud)

These services are deployed **ONCE** and serve **ALL customers**, drastically reducing per-customer infrastructure costs.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SHARED INFRASTRUCTURE                     │
│                    (deployed once)                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Mailcow   │  │  Nextcloud  │  │  Keycloak   │         │
│  │   cx43      │  │    cx43     │  │    cx33     │         │
│  │ ~€16/month  │  │  ~€16/month │  │  ~€9/month  │         │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │
│         │                │                │                 │
│         └────────────────┼────────────────┘                 │
│                          │                                  │
│                 ┌────────┴────────┐                        │
│                 │  Load Balancer  │                        │
│                 │      lb11       │                        │
│                 │   ~€6/month     │                        │
│                 └────────┬────────┘                        │
│                          │                                  │
│            ┌─────────────┴─────────────┐                   │
│            │     Private Network       │                   │
│            │      10.0.0.0/16          │                   │
│            └───────────────────────────┘                   │
│                                                             │
│            Total: ~€47/month (fixed cost)                  │
└─────────────────────────────────────────────────────────────┘

Per-Customer: Only Desktop Server (~€9/month each)
```

## Cost Comparison

| Model | Per Customer | 10 Customers | 100 Customers |
|-------|-------------|--------------|---------------|
| **Old (Full Stack)** | €120/month | €1,200/month | €12,000/month |
| **New (Shared)** | €9/month + €47 shared | €137/month | €947/month |
| **Savings** | - | **€1,063/month** | **€11,053/month** |

## Prerequisites

1. **Terraform Cloud Workspace**: Create workspace `shared-infrastructure` in organization `swiss365`
2. **Hetzner Cloud Token**: Set `TF_VAR_hcloud_token` in Terraform Cloud
3. **SSH Key**: Ensure `swiss365-key` exists in Hetzner Cloud
4. **DNS Zone**: `swiss365.cloud` must be configured in Hetzner DNS

## Deployment

### Initial Deployment (One-Time)

```bash
# Via GitHub Actions (recommended)
# Go to Actions → "Deploy Shared Infrastructure" → Run workflow

# Or manually via Terraform Cloud
cd terraform-changes/shared-infrastructure
terraform init
terraform plan
terraform apply
```

### Post-Deployment Steps

1. **DNS Configuration**: The GitHub workflow automatically creates DNS records
2. **Service Registration**: Services are automatically registered in Supabase `shared_services` table
3. **Health Check**: Verify all services are healthy in Admin Dashboard

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `hcloud_token` | Hetzner API token | (required) |
| `ssh_key_name` | SSH key name in Hetzner | `swiss365-key` |
| `location` | Datacenter location | `fsn1` |
| `mailcow_domain` | Mailcow domain | `mail.swiss365.cloud` |
| `nextcloud_domain` | Nextcloud domain | `cloud.swiss365.cloud` |
| `keycloak_domain` | Keycloak domain | `auth.swiss365.cloud` |

## Outputs

After deployment, the following outputs are available:

- `mailcow_ip` - Public IP of Mailcow server
- `nextcloud_ip` - Public IP of Nextcloud server
- `keycloak_ip` - Public IP of Keycloak server
- `load_balancer_ip` - Public IP of Load Balancer
- `mailcow_admin_password` - Admin password for Mailcow
- `nextcloud_admin_password` - Admin password for Nextcloud
- `keycloak_admin_password` - Admin password for Keycloak

## Multi-Tenant Configuration

### Mailcow
- Each customer gets a **domain** configured in Mailcow
- Mailboxes are created per-customer under their domain
- API: `https://mail.swiss365.cloud/api/v1/`

### Nextcloud
- Each customer gets a **group** and **quota**
- Users are provisioned via Provisioning API
- API: `https://cloud.swiss365.cloud/ocs/v1.php/cloud/`

### Keycloak
- Each customer gets a **realm**
- SSO integration with Mailcow and Nextcloud
- API: `https://auth.swiss365.cloud/admin/realms/`

## Troubleshooting

### Services not accessible
1. Check Load Balancer health in Hetzner Console
2. Verify DNS records point to Load Balancer IP
3. Check server status in Admin Dashboard

### Database initialization failed
1. SSH into server and check Docker logs
2. Verify cloud-init completed successfully
3. Check `/var/log/cloud-init-output.log`

### Health checks failing
1. Verify services are running: `docker ps`
2. Check correct ports are exposed
3. Verify firewall allows traffic

## Maintenance

### Scaling
- Mailcow/Nextcloud: Upgrade server type in variables
- Add more storage via Hetzner Volumes

### Backups
- Automated daily backups via backup-manager Edge Function
- Hetzner Snapshots for disaster recovery

### Updates
- Mailcow: `cd /opt/mailcow-dockerized && ./update.sh`
- Nextcloud: Via admin panel or `occ upgrade`
- Keycloak: Update Docker image tag
