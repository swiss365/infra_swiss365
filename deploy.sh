#!/usr/bin/env bash
set -euo pipefail

terraform init -input=false

if [ -n "${TF_WORKSPACE:-}" ]; then
  terraform workspace select "$TF_WORKSPACE" || terraform workspace new "$TF_WORKSPACE"
fi

terraform apply -auto-approve "$@"

ansible-playbook ansible/site.yml

terraform output -json > deployment_outputs.json
jq -r 'to_entries[] | "\(.key)=\(.value.value)"' deployment_outputs.json | tee deployment_credentials.txt

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  jq -r 'to_entries[] | "\(.key)=\(.value.value)"' deployment_outputs.json >> "$GITHUB_OUTPUT"
fi

echo "Deployment credentials saved to deployment_credentials.txt"
