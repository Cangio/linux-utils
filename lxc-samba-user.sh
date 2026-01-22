#!/bin/bash

# Exit on any error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "This script must be run as root"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    echo "Detected OS: $PRETTY_NAME"
else
    echo "Cannot detect OS. This script supports Debian and Ubuntu systems."
    exit 1
fi

# Check if OS is supported
if [[ "$OS" != "debian" && "$OS" != "ubuntu" ]]; then
    echo "Unsupported OS: $OS"
    echo "This script only supports Debian and Ubuntu systems."
    exit 1
fi

echo "Starting Samba configuration..."

# Check if Samba is installed
if ! command -v smbpasswd &> /dev/null; then
    echo "Samba is not installed. Installing..."
    apt-get update
    apt-get install -y samba
    echo "Samba installed successfully."
else
    echo "Samba is already installed."
fi

# Enable root login in Samba configuration
SAMBA_CONF="/etc/samba/smb.conf"

# Backup the original configuration
cp "$SAMBA_CONF" "${SAMBA_CONF}.backup.$(date +%Y%m%d_%H%M%S)"

# Check if [global] section allows invalid users or needs modification
# Add configuration to allow root login if not present
if ! grep -q "invalid users = " "$SAMBA_CONF"; then
    sed -i '/\[global\]/a \   invalid users = ' "$SAMBA_CONF"
    echo "Configured Samba to allow root user login."
else
    # Remove root from invalid users list if present
    sed -i 's/invalid users = .*root.*/invalid users = /' "$SAMBA_CONF"
    echo "Updated Samba configuration to allow root user."
fi

# Determine which user to configure
echo ""
echo "Detecting users in /home directory..."
HOME_USERS=($(ls -1 /home 2>/dev/null | grep -v "lost+found" || true))

if [ ${#HOME_USERS[@]} -eq 0 ]; then
    echo "No users found in /home directory."
    read -p "Enter username to configure for Samba: " TARGET_USER
elif [ ${#HOME_USERS[@]} -eq 1 ]; then
    TARGET_USER="${HOME_USERS[0]}"
    echo "Found one user: $TARGET_USER"
    read -p "Configure Samba for user '$TARGET_USER'? (y/n): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        read -p "Enter username to configure for Samba: " TARGET_USER
    fi
else
    echo "Multiple users found in /home:"
    for user in "${HOME_USERS[@]}"; do
        echo "  - $user"
    done
    read -p "Enter username to configure for Samba: " TARGET_USER
fi

# Verify user exists
if ! id "$TARGET_USER" &>/dev/null; then
    echo "Error: User '$TARGET_USER' does not exist on this system."
    exit 1
fi

# Verify home directory exists
USER_HOME="/home/$TARGET_USER"
if [ ! -d "$USER_HOME" ]; then
    echo "Error: Home directory $USER_HOME does not exist."
    exit 1
fi

echo ""
echo "Setting Samba password for user '$TARGET_USER'..."
echo "Please enter the password when prompted:"
echo ""

# Set Samba password for the user
smbpasswd -a "$TARGET_USER"

# Add share configuration for user's home directory
echo ""
echo "Adding share configuration for $USER_HOME..."

SHARE_NAME="$TARGET_USER"
SHARE_CONFIG="

[$SHARE_NAME]
   path = $USER_HOME
   browseable = yes
   read only = no
   valid users = $TARGET_USER
   create mask = 0644
   directory mask = 0755"

# Check if share already exists
if grep -q "^\[$SHARE_NAME\]" "$SAMBA_CONF"; then
    echo "Share [$SHARE_NAME] already exists in configuration. Skipping..."
else
    echo "$SHARE_CONFIG" >> "$SAMBA_CONF"
    echo "Share [$SHARE_NAME] added to Samba configuration."
fi

# Restart Samba services
echo ""
echo "Restarting Samba services..."
systemctl restart smbd
systemctl restart nmbd

echo ""
echo "Configuration complete!"
echo "User '$TARGET_USER' can now login to Samba with the password you set."
echo "Share available: \\\\<server-ip>\\$SHARE_NAME"
