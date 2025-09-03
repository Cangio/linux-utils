# linux-utils
Some useful .sh scripts

Initial commands:
```
sudo apt update && sudo apt upgrade -yy && sudo apt install git curl vim -yy
```

Proxmox Qemu agent:
```
sudo apt install qemu-guest-agent
```

## Add sudo package
```
curl -o sudo-install.sh https://raw.githubusercontent.com/Cangio/linux-utils/main/sudo-install.sh
chmod +x sudo-install.sh
./sudo-install.sh
rm sudo-install.sh
```

## SMB and NFS
Install dependencies:
```
sudo apt update sudo apt install nfs-common
```

Mount NFS location:
```
sudo mount -t nfs {IP of NFS server}:{folder path on server} /mnt/local-folder
```


## Install docker on ubuntu
```
curl -o install-docker.sh https://raw.githubusercontent.com/Cangio/linux-utils/main/docker-ubuntu-install.sh
chmod +x install-docker.sh
./install-docker.sh
```

## Install docker on debian
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Cangio/linux-utils/main/docker-debian-install.sh)"
```

```
curl -o install-docker.sh https://raw.githubusercontent.com/Cangio/linux-utils/main/docker-debian-install.sh
chmod +x install-docker.sh
./install-docker.sh
```
