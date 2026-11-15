#!/usr/bin/env bash
set -euo pipefail

# Make sure the script is run with sudo privileges
[[ $EUID -eq 0 ]] || { echo "This script must be run with sudo."; exit 1; }

# Check if Docker is already installed
if command -v docker >/dev/null && docker compose version >/dev/null 2>&1; then
  echo "Docker is already installed."
  exit 0
fi

# Set log limit before installing Docker
mkdir -p /etc/docker
[[ -f /etc/docker/daemon.json ]] || echo '{ "log-driver": "json-file", "log-opts": { "max-size": "10m", "max-file": "3" } }' > /etc/docker/daemon.json

# Install Docker and Docker Compose
curl -fsSL https://get.docker.com | sh

# Enable and start Docker service
systemctl enable --now docker
