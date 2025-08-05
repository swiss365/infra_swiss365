#!/usr/bin/env bash
# Periodically verify and restart the Guacamole docker stack
# Usage: ./scripts/watch_docker_stack.sh [host] [interval_seconds]
set -euo pipefail

HOST=${1:-desktop_pool}
INTERVAL=${2:-300}
INVENTORY="ansible/inventory.yml"

while true; do
  if ! ansible -i "$INVENTORY" "$HOST" -m shell -a "docker ps --format '{{.Names}}'" | grep -q 'guacamole_' ; then
    echo "Guacamole containers not running on $HOST – restarting stack"
    ansible -i "$INVENTORY" "$HOST" -m community.docker.docker_compose -a "project_src=/opt/guacamole state=restarted"
  fi
  ansible -i "$INVENTORY" "$HOST" -m shell -a "docker ps --format '{{.Names}} {{.Status}}'"
  sleep "$INTERVAL"
done
