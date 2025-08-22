#!/usr/bin/env bash
set -euo pipefail

# determine if sudo is needed for apt-get
if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  SUDO=""
fi

# Install Terraform
if ! command -v terraform >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    # Add HashiCorp repo if not already present
    if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
      $SUDO curl -fsSL https://apt.releases.hashicorp.com/gpg \
        | $SUDO gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        $SUDO tee /etc/apt/sources.list.d/hashicorp.list
    fi
    $SUDO apt-get update
    $SUDO apt-get install -y terraform
  else
    echo "Please install Terraform manually: https://developer.hashicorp.com/terraform/install" >&2
  fi
fi

# Install Ansible and helper packages
if ! command -v ansible-playbook >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y ansible jq python3-pip sshpass
  else
    pip3 install --user ansible jq sshpass
    export PATH="$PATH:$HOME/.local/bin"
  fi
fi

# Print versions
if command -v terraform >/dev/null 2>&1; then
  terraform --version
fi
if command -v ansible >/dev/null 2>&1; then
  ansible --version | head -n 1
fi
