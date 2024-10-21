# linux-utils
Some useful .sh scripts

Initial commands:
```
sudo apt update && sudo apt upgrade -yy && sudo apt install git vim -yy
```

## Add sudo package
```
curl -o sudo-install.sh https://raw.githubusercontent.com/Cangio/linux-utils/main/sudo-install.sh
chmod +x sudo-install.sh
./sudo-install.sh
rm sudo-install.sh
```

## Install docker on ubuntu
```
curl -o install-docker.sh https://raw.githubusercontent.com/Cangio/linux-utils/main/docker-ubuntu-install.sh
chmod +x install-docker.sh
./install-docker.sh
```

## Install docker on debian
```
curl -o install-docker.sh https://raw.githubusercontent.com/Cangio/linux-utils/main/docker-debian-install.sh
chmod +x install-docker.sh
./install-docker.sh
```
