#!/usr/bin/env bash
# Simple helper to verify and restart the Guacamole docker stack
# Usage: ./scripts/check_docker_status.sh [host]
set -euo pipefail

HOST=${1:-desktop_pool}
INVENTORY="ansible/inventory.yml"

check_containers() {
  ansible -i "$INVENTORY" "$HOST" -m shell -a "docker ps --format '{{.Names}} {{.Status}}'"
}

restart_stack() {
  ansible -i "$INVENTORY" "$HOST" -m community.docker.docker_compose_v2 -a "project_src=/opt/guacamole state=restarted"
}

# Restart the stack if no Guacamole containers are found
if ! ansible -i "$INVENTORY" "$HOST" -m shell -a "docker ps --format '{{.Names}}'" | grep -q 'guacamole_' ; then
  echo "Guacamole containers not running on $HOST – restarting stack"
  restart_stack
fi

# Always print current container status
check_containers
