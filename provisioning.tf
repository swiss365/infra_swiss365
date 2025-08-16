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
    control_pw   = random_password.control_pw.result
    workspace_pw = random_password.workspace_pw.result
    desktop_pw   = random_password.desktop_pool_pw.result
  }

  provisioner "local-exec" {
    command     = <<EOT
if ! command -v ansible-playbook >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y ansible jq python3-pip
  pip3 install docker
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
          ansible_password: ${self.triggers.control_pw}
          ansible_connection: ssh
          guac_rdp_password: ${self.triggers.control_pw}
    workspace:
      hosts:
        workspace:
          ansible_host: ${self.triggers.workspace_ip}
          ansible_user: root
          ansible_password: ${self.triggers.workspace_pw}
          ansible_connection: ssh
          guac_rdp_password: ${self.triggers.workspace_pw}
    desktop_pool:
      hosts:
        desktop_pool:
          ansible_host: ${self.triggers.desktop_ip}
          ansible_user: root
          ansible_password: ${self.triggers.desktop_pw}
          ansible_connection: ssh
          guac_rdp_password: ${self.triggers.desktop_pw}
EOF_INVENTORY

ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/site.yml
EOT
    working_dir = path.root
  }
}
