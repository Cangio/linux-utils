#!/bin/bash

# Traefik configuration
install_traefik () {
  mkdir traefik
  mkdir traefik/acme
  touch traefik/acme/acme.json
  chmod 0600 traefik/acme/acme.json
  curl -o traefik/traefik.yml https://github.com/Cangio/linux-utils/new/main
  curl -o traefik/config.yml https://github.com/Cangio/linux-utils/new/main
}

# Create network t2_proxy if not existent
docker network inspect t2_proxy >/dev/null 2>&1 || \
  docker network create -d bridge --ip 10.2.0.0/16 --subnet 10.2.0.0/24 --gateway 10.2.0.1 t2_proxy
touch .env

# Ask for Traefik installation
while true; do
    read -p "Do you wish to install Traefik? " yn
    case $yn in
        [Yy]* ) install_traefik; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done




