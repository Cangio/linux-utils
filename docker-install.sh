#!/bin/bash

################################################################################
# Docker Installation Script for Debian/Ubuntu Systems
#
# Author: Simone Cangini
# Email: simone@simonecangini.it
# Date: 22/01/2026
#
# Description:
#   This script automates the installation of Docker Engine and Docker Compose
#   on Debian and Ubuntu-based systems. It automatically detects the operating
#   system type and configures the appropriate Docker repository. The script
#   can be run by both root and non-root users, handling permissions and user
#   group assignments accordingly.
#
# Features:
#   - Automatic OS detection (Debian/Ubuntu)
#   - Compatible with both root and non-root execution
#   - Installs latest Docker Engine from official repository
#   - Downloads and installs latest Docker Compose version
#   - Configures docker group and user permissions
#   - Creates initial docker workspace directory
#
#
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Determine if running as root
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
    USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
    ACTUAL_USER=${SUDO_USER:-$USER}
else
    SUDO="sudo"
    USER_HOME=$HOME
    ACTUAL_USER=$USER
fi

echo -e "${GREEN}Docker Installation Script for Debian/Ubuntu${NC}"
echo "=============================================="

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Cannot detect OS. /etc/os-release not found.${NC}"
    exit 1
fi

# Validate OS is Debian or Ubuntu
if [ "$OS" != "ubuntu" ] && [ "$OS" != "debian" ]; then
    echo -e "${RED}This script only supports Ubuntu and Debian.${NC}"
    echo "Detected OS: $OS"
    exit 1
fi

echo -e "${YELLOW}Detected OS: $OS${NC}"

# Update package list
echo -e "${GREEN}Updating package list...${NC}"
$SUDO apt update

# Install prerequisites
echo -e "${GREEN}Installing prerequisites...${NC}"
$SUDO apt-get install -yy ca-certificates curl gnupg lsb-release

# Create keyrings directory
echo -e "${GREEN}Setting up Docker repository...${NC}"
$SUDO mkdir -p /etc/apt/keyrings

# Add Docker's official GPG key (OS-specific)
if [ "$OS" = "ubuntu" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
elif [ "$OS" = "debian" ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

# Update package list with Docker repository
echo -e "${GREEN}Updating package list with Docker repository...${NC}"
$SUDO apt update

# Install Docker
echo -e "${GREEN}Installing Docker...${NC}"
$SUDO apt-get install -yy docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
echo -e "${GREEN}Adding user to docker group...${NC}"
$SUDO groupadd docker 2>/dev/null || true
$SUDO usermod -aG docker $ACTUAL_USER

# Get latest Docker Compose version
echo -e "${GREEN}Fetching latest Docker Compose version...${NC}"
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

if [ -z "$COMPOSE_VERSION" ]; then
    echo -e "${YELLOW}Could not fetch latest version, using v2.24.5${NC}"
    COMPOSE_VERSION="v2.24.5"
else
    echo -e "${GREEN}Latest Docker Compose version: $COMPOSE_VERSION${NC}"
fi

# Download and install Docker Compose standalone
echo -e "${GREEN}Installing Docker Compose standalone binary...${NC}"
$SUDO curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$SUDO chmod +x /usr/local/bin/docker-compose

# Create symlink if it doesn't exist
if [ ! -f /usr/bin/docker-compose ]; then
    $SUDO ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# Create docker directory for user
echo -e "${GREEN}Creating docker workspace...${NC}"
mkdir -p $USER_HOME/dockers
touch $USER_HOME/dockers/.env

# Fix ownership if running as root
if [ "$(id -u)" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/dockers
fi

# Verify installation
echo ""
echo -e "${GREEN}=============================================="
echo "Installation Summary"
echo -e "==============================================${NC}"
docker --version
docker compose version
/usr/local/bin/docker-compose --version 2>/dev/null || echo "Docker Compose standalone: installed"

echo ""
echo -e "${GREEN}✓ Docker installed successfully!${NC}"
echo -e "${GREEN}✓ Docker Compose plugin installed!${NC}"
echo -e "${GREEN}✓ Docker Compose standalone installed!${NC}"
echo -e "${GREEN}✓ User '$ACTUAL_USER' added to docker group${NC}"
echo -e "${GREEN}✓ Docker workspace created at ~/dockers${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Log out and log back in for group changes to take effect!${NC}"
echo -e "${YELLOW}Or run: newgrp docker${NC}"
