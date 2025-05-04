#!/bin/bash

# Color codes for better visual experience
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define installation paths
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="stat-helper"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"

# Check if running with sudo/root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root or with sudo privileges${NC}"
    exit 1
fi

echo -e "${BLUE}${BOLD}Installing Kubernetes & Docker Monitoring Tool...${NC}"
echo

# Copy the main script to the installation directory
cp stat-helper.sh "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

echo -e "${GREEN}Installation completed!${NC}"
echo -e "You can now run the tool by typing: ${BOLD}$SCRIPT_NAME${NC}"
echo
echo -e "${YELLOW}Note:${NC} If you move the script, you may need to run this installer again."