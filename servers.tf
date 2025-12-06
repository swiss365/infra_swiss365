resource "random_password" "control_pw" {
  length  = 16
  special = false
}

module "control_node" {
  source             = "./modules/server_common"
  name               = "${var.customer_id}-control"
  server_type        = "cpx31"
  image              = var.image
  network_id         = hcloud_network.swiss365_net.id
  ssh_key_name       = var.ssh_key_name
  root_password_hash = bcrypt(random_password.control_pw.result)
  labels = {
    customer = var.customer_id
  }
  extra_cloud_init = <<-EOF
  - sleep 120
  - apt-get update
  - apt-get install -y ansible git
  - mkdir -p /root/.ssh
  - echo "${var.ssh_private_key}" | base64 -d > /root/.ssh/id_rsa
  - chmod 600 /root/.ssh/id_rsa
  - |
    cat > /root/inventory.yml <<'INVENTORY'
    all:
      children:
        control:
          hosts:
            localhost:
              ansible_connection: local
        workspace:
          hosts:
            workspace:
              ansible_host: ${module.workspace_host.ipv4}
              ansible_user: root
              ansible_ssh_private_key_file: /root/.ssh/id_rsa
        desktop_pool:
          hosts:
            desktop_pool:
              ansible_host: ${module.desktop_pool_host.ipv4}
              ansible_user: root
              ansible_ssh_private_key_file: /root/.ssh/id_rsa
    INVENTORY
  - cd /root && git clone https://github.com/swiss365/infra_swiss365.git
  - |
    for host in ${module.workspace_host.ipv4} ${module.desktop_pool_host.ipv4}; do
      until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@$$host echo ok 2>/dev/null; do
        echo "Waiting for $$host..."
        sleep 10
      done
    done
  - ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /root/inventory.yml /root/infra_swiss365/ansible/site.yml
  - touch /root/.provisioning_complete
  EOF
}

resource "random_password" "workspace_pw" {
  length  = 16
  special = false
}

module "workspace_host" {
  source             = "./modules/server_common"
  name               = "${var.customer_id}-workspace"
  server_type        = "cpx51"
  image              = var.image
  network_id         = hcloud_network.swiss365_net.id
  ssh_key_name       = var.ssh_key_name
  root_password_hash = bcrypt(random_password.workspace_pw.result)
  labels = {
    customer = var.customer_id
  }
}

resource "random_password" "desktop_pool_pw" {
  length  = 16
  special = false
}

module "desktop_pool_host" {
  source             = "./modules/server_common"
  name               = "${var.customer_id}-desktop-pool"
  server_type        = "cpx51"
  image              = var.image
  network_id         = hcloud_network.swiss365_net.id
  ssh_key_name       = var.ssh_key_name
  root_password_hash = bcrypt(random_password.desktop_pool_pw.result)
  labels = {
    customer = var.customer_id
  }
}
