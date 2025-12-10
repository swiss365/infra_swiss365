# Swiss365 Terraform Infrastructure

Vollständige Terraform-Konfiguration für das Swiss365 MSP-Infrastrukturmanagement.

## Dateistruktur

```
infra_swiss365/
├── versions.tf          # Terraform & Provider Versionen
├── providers.tf         # Provider Konfiguration (hcloud, random)
├── variables.tf         # Input Variablen
├── network.tf           # Private Netzwerk & Subnet
├── servers.tf           # Server Module (Control, Workspace, Desktop)
├── load_balancer.tf     # Load Balancer Konfiguration
├── outputs.tf           # Terraform Outputs
└── modules/
    ├── control_node/
    │   ├── main.tf          # Control Node Server
    │   └── cloud_init.yml   # Guacamole Installation
    ├── server_common/
    │   ├── main.tf          # Standard Server
    │   └── cloud_init.yml   # xrdp/xfce4 Installation
    └── lb_guacamole/
        └── main.tf          # Load Balancer für Guacamole
```

## Wichtige Hinweise

### 1. DNS-Management
DNS wird **NICHT** über Terraform verwaltet! Die DNS-Records werden automatisch über die Supabase Edge Function `hetzner-dns-manager` erstellt, nachdem das Terraform Apply erfolgreich war.

### 2. Server-Typen
Alle Server verwenden standardmäßig:
- **Server-Typ:** `cx32` (4 vCPU, 8GB RAM)
- **Standort:** `fsn1` (Falkenstein - größtes Hetzner Rechenzentrum)
- **Image:** `ubuntu-24.04`

### 3. Load Balancer
- Health Check Pfad: `/guacamole/`
- Verwendet **private IP** für Backend-Kommunikation
- HTTPS mit automatischem Zertifikat

## Installation

```bash
# 1. Repository klonen
git clone https://github.com/your-org/infra_swiss365.git
cd infra_swiss365

# 2. Alle Dateien aus terraform-changes/ kopieren
cp -r terraform-changes/* .

# 3. Terraform initialisieren
terraform init

# 4. Plan erstellen
terraform plan -var="customer_id=testcustomer" -var="guacamole_domain=testcustomer.swiss365.cloud"

# 5. Apply
terraform apply -var="customer_id=testcustomer" -var="guacamole_domain=testcustomer.swiss365.cloud"
```

## Terraform Cloud Variablen

Diese Variablen müssen in Terraform Cloud konfiguriert sein:

| Variable | Typ | Beschreibung |
|----------|-----|--------------|
| `hcloud_token` | Environment (TF_VAR_hcloud_token) | Hetzner Cloud API Token |
| `customer_id` | Terraform | Kunden-Identifier |
| `guacamole_domain` | Terraform | Domain für Guacamole |
| `ssh_key_name` | Terraform | SSH-Key Name in Hetzner |

## Nach dem Deployment

1. **Warte 5-10 Minuten** bis Cloud-Init abgeschlossen ist
2. **DNS-Record wird automatisch erstellt** via Edge Function
3. **Öffne** `https://<customer_id>.swiss365.cloud/guacamole`
4. **Login:** `guacadmin` / `guacadmin`
5. **WICHTIG:** Ändere das Passwort nach dem ersten Login!

## Debugging

### SSH zum Control Node
```bash
ssh -i ~/.ssh/swiss365_key root@<control_ip>
```

### Cloud-Init Logs prüfen
```bash
cat /var/log/swiss365/install.log
cat /var/log/cloud-init-output.log
```

### Docker Container prüfen
```bash
docker ps -a
docker logs guacamole
docker logs guacamole_db
```

### Status API abfragen
```bash
curl http://<control_ip>:8081
```

## Module

### control_node
- Installiert Docker via Cloud-Init
- Deployed Guacamole mit PostgreSQL
- Konfiguriert RDP-Verbindungen zu anderen Servern
- Stellt Status-API auf Port 8081 bereit

### server_common
- Installiert xrdp und xfce4 Desktop
- Ermöglicht RDP-Zugang via Guacamole
- Stellt Status-API auf Port 8081 bereit

### lb_guacamole
- Load Balancer für Guacamole
- Health Check auf /guacamole/
- HTTP (80) und HTTPS (443) auf Port 8080

## Architektur

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet                                  │
│                        │                                     │
│                        ▼                                     │
│            ┌─────────────────────┐                          │
│            │   Load Balancer     │                          │
│            │ (customer.swiss365) │                          │
│            └──────────┬──────────┘                          │
│                       │ :80/:443 → :8080                    │
│                       ▼                                     │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │                  Private Network                         │ │
│ │                    10.0.0.0/16                          │ │
│ │                                                          │ │
│ │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │ │
│ │  │ Control Node │  │  Workspace   │  │ Desktop Pool │  │ │
│ │  │  (Guacamole) │  │   Server     │  │    Server    │  │ │
│ │  │   :8080      │  │   :3389      │  │    :3389     │  │ │
│ │  └──────────────┘  └──────────────┘  └──────────────┘  │ │
│ │         │                  ▲                 ▲          │ │
│ │         └──────── RDP ─────┴─────────────────┘          │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Gelöschte Dateien

Diese Dateien existieren nicht mehr und sollten entfernt werden falls vorhanden:

- `provisioning.tf` - Ansible-Provisioning wurde durch Cloud-Init ersetzt
- Alle `hetznerdns` Provider-Referenzen - DNS via Edge Function
