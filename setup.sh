#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a package
install_package() {
    echo "$1 is not installed. Installing..."
    sudo apt update
    sudo apt install -y "$1"
}

setup_docker() {
    # Add Docker's official GPG key:
    sudo apt update
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    systemctl restart docker
}

# Check and install binutils (includes ld)
if ! command_exists "ld"; then
    install_package "binutils"
fi

# Check and install curl
if ! command_exists "curl"; then
    install_package "curl"
fi

# Check and install make
if ! command_exists "make"; then
    install_package "make"
fi

# Check and install docker-compose
if ! command_exists "docker-compose"; then
    setup_docker
fi

# Check and install grep
if ! command_exists "grep"; then
    install_package "grep"
fi

# Check and install sort
if ! command_exists "sort"; then
    install_package "coreutils"
fi

# Check and install uniq
if ! command_exists "uniq"; then
    install_package "coreutils"
fi

# Check and install sed
if ! command_exists "sed"; then
    install_package "sed"
fi

# Check and install tar
if ! command_exists "tar"; then
    install_package "tar"
fi

# Check and install strings (part of binutils)
if ! command_exists "strings"; then
    install_package "binutils"
fi

# Check and install uname (part of coreutils)
if ! command_exists "uname"; then
    install_package "coreutils"
fi

echo "All required tools are installed and up to date!"