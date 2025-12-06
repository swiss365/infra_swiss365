resource "null_resource" "configure_servers" {
  depends_on = [
    module.control_node,
    module.workspace_host,
    module.desktop_pool_host,
    module.guac_lb
  ]

  triggers = {
    control_ip   = module.control_node.ipv4
    workspace_ip = module.workspace_host.ipv4
    desktop_ip   = module.desktop_pool_host.ipv4
  }

  provisioner "local-exec" {
    command     = <<EOT
# SSH Key für Ansible bereitstellen
mkdir -p ~/.ssh
echo "${var.ssh_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

if ! command -v ansible-playbook >/dev/null 2>&1; then
  pip3 install --user ansible jq
  export PATH="$PATH:$HOME/.local/bin"
  pip3 install --user docker
  ansible-galaxy collection install community.docker
fi

cat > ansible/inventory.yml <<'EOF_INVENTORY'
all:
  children:
    control:
      hosts:
        control:
          ansible_host: ${self.triggers.control_ip}
          ansible_user: root
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          ansible_connection: ssh
    workspace:
      hosts:
        workspace:
          ansible_host: ${self.triggers.workspace_ip}
          ansible_user: root
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          ansible_connection: ssh
    desktop_pool:
      hosts:
        desktop_pool:
          ansible_host: ${self.triggers.desktop_ip}
          ansible_user: root
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          ansible_connection: ssh
EOF_INVENTORY

ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/site.yml
EOT
    working_dir = path.root
  }
}
