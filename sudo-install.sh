#!/bin/sh

apt install -yy sudo
echo "Insert user to be enabled: "
read uenable
usermod -aG sudo $uenable

echo "OK."
