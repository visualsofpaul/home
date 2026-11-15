#!/usr/bin/env bash
set -euo pipefail

# Set up the variables
REPO="visualsofpaul/home"
RAW="https://raw.githubusercontent.com/$REPO/main"
DEST="/opt/home"

# Make sure the script is run with sudo privileges
[[ $EUID -eq 0 ]] || { echo "This script must be run with sudo."; exit 1; }

# Install Docker and Docker Compose if not already installed
bash <(curl -fsSL "$RAW/scripts/bootstrap.sh")

# Create the destination directory and download the compose.yml and stacks files
mkdir -p "$DEST" && cd "$DEST"
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/main" \
  | tar -xz --strip-components=1 --wildcards '*/compose.yml' '*/stacks/*'

# Set up the .env file if it doesn't exist
if [[ ! -e .env ]]; then
  read -rp "Domain [home.lab]: " DOMAIN
  read -rp "Data directory [/srv/data]: " DATA_DIR
  cat > .env <<EOF
DOMAIN=${DOMAIN:-home.lab}
DATA_DIR=${DATA_DIR:-/srv/data}
TZ=$(timedatectl show -p Timezone --value 2>/dev/null || echo Europe/Berlin)
EOF
  chmod 600 .env
fi

# Create the Docker network and start the containers
docker network create proxy 2>/dev/null || true
docker compose up -d
