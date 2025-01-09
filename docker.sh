#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting package removal..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  echo "Removing package $pkg..."
  if dpkg -l | grep -q $pkg; then
    sudo apt-get remove -y $pkg || { echo "Error removing $pkg"; exit 1; }
  else
    echo "$pkg is not installed, skipping..."
  fi
done

echo "Updating package list..."
sudo apt-get update || { echo "Error updating package list"; exit 1; }

echo "Installing prerequisites..."
sudo apt-get install -y ca-certificates curl || { echo "Error installing prerequisites"; exit 1; }

echo "Creating directory for keyrings..."
sudo install -m 0755 -d /etc/apt/keyrings || { echo "Error creating keyrings directory"; exit 1; }

echo "Downloading Docker GPG key..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || { echo "Error downloading Docker GPG key"; exit 1; }

echo "Setting permissions for Docker GPG key..."
sudo chmod a+r /etc/apt/keyrings/docker.asc || { echo "Error setting permissions for Docker GPG key"; exit 1; }

# Add Docker's official repository to apt sources
echo "Adding Docker repository to apt sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || { echo "Error adding Docker repository"; exit 1; }

echo "Updating package list after adding Docker repository..."
sudo apt-get update || { echo "Error updating package list after adding Docker repository"; exit 1; }

echo "Installing Docker components..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || { echo "Error installing Docker components"; exit 1; }

echo "Docker installation completed successfully!"
