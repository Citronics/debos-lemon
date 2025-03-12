#!/bin/bash
set -e

echo "Setting root password to 'root'..."
echo "root:root" | chpasswd
passwd -u root 2>/dev/null || echo "Root account already unlocked"

echo "Creating user 'user' with password 'debian'..."
useradd -m -s /bin/bash user
echo "user:debian" | chpasswd

echo "Adding user to sudo group..."
usermod -aG sudo user

echo "Setup complete!"
