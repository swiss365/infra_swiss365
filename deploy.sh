#!/usr/bin/env bash
set -euo pipefail

# Ensure Ansible and required tools are installed
if ! command -v ansible-playbook >/dev/null 2>&1; then
  if command -v sudo >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y ansible jq python3-pip
  else
    apt-get update && apt-get install -y ansible jq python3-pip
  fi
  pip3 install docker
  ansible-galaxy collection install community.docker
fi


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
          ansible_connection: ssh
          guac_rdp_password: $control_pw
    workspace:
      hosts:
        workspace:
          ansible_host: $workspace_ip
          ansible_user: root
          ansible_password: $workspace_pw
          ansible_connection: ssh
          guac_rdp_password: $workspace_pw
    desktop_pool:
      hosts:
        desktop_pool:
          ansible_host: $desktop_ip
          ansible_user: root
          ansible_password: $desktop_pw
          ansible_connection: ssh
          guac_rdp_password: $desktop_pw
EOF

pushd ansible >/dev/null
ansible-playbook site.yml
popd >/dev/null

terraform output -json > deployment_outputs.json
for key in $(jq -r 'keys[]' deployment_outputs.json); do
  val=$(terraform output -raw "$key")
  echo "$key=$val"
done | tee deployment_credentials.txt

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  cat deployment_credentials.txt >> "$GITHUB_OUTPUT"
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  jq -r 'to_entries[] | "\(.key)=\(.value.value)"' deployment_outputs.json >> "$GITHUB_OUTPUT"
fi

echo "Deployment credentials saved to deployment_credentials.txt"
