#!/usr/bin/env bash
set -euo pipefail

terraform init -input=false

if [ -n "${TF_WORKSPACE:-}" ]; then
  terraform workspace select "$TF_WORKSPACE" || terraform workspace new "$TF_WORKSPACE"
fi

terraform apply -auto-approve "$@"

# Generate dynamic inventory with host credentials
control_ip=$(terraform output -raw control_public_ip)
workspace_ip=$(terraform output -raw workspace_public_ip)
desktop_ip=$(terraform output -raw desktop_pool_public_ip)
control_pw=$(terraform output -raw control_root_password)
workspace_pw=$(terraform output -raw workspace_root_password)
desktop_pw=$(terraform output -raw desktop_pool_root_password)

cat > ansible/inventory.yml <<EOF
all:
  children:
    control:
      hosts:
        control:
          ansible_host: $control_ip
          ansible_user: root
          ansible_password: $control_pw
          guac_rdp_password: $control_pw
    workspace:
      hosts:
        workspace:
          ansible_host: $workspace_ip
          ansible_user: root
          ansible_password: $workspace_pw
          guac_rdp_password: $workspace_pw
    desktop_pool:
      hosts:
        desktop_pool:
          ansible_host: $desktop_ip
          ansible_user: root
          ansible_password: $desktop_pw
          guac_rdp_password: $desktop_pw
EOF

ansible-playbook ansible/site.yml

terraform output -json > deployment_outputs.json
for key in $(jq -r 'keys[]' deployment_outputs.json); do
  val=$(terraform output -raw "$key")
  echo "$key=$val"
done | tee deployment_credentials.txt

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  cat deployment_credentials.txt >> "$GITHUB_OUTPUT"
fi

echo "Deployment credentials saved to deployment_credentials.txt"
