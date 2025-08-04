#!/usr/bin/env bash
set -euo pipefail

terraform init -input=false
terraform apply -auto-approve "$@"

ansible-playbook ansible/site.yml

terraform output -json > deployment_outputs.json
jq -r 'to_entries[] | "\(.key)=\(.value.value)"' deployment_outputs.json | tee deployment_credentials.txt

echo "Deployment credentials saved to deployment_credentials.txt"
