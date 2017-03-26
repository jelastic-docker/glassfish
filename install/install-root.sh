#!/bin/bash

# Install OpenJDK 8 and some packages to removed later
echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
apt-get update
apt-get install -yt jessie-backports openjdk-8-jre-headless
apt-get install -y wget unzip openjdk-8-jdk openssh-server

# Configure SSH
echo "root:${PASSWORD}" | chpasswd
sed -i 's|#PubkeyAuthentication yes|PubkeyAuthentication yes|g' /etc/ssh/sshd_config
sed -i 's|#StrictModes yes|StrictModes yes|g' /etc/ssh/sshd_config
sed -i 's|#AuthorizedKeysFile	%h/.ssh/authorized_keys|AuthorizedKeysFile	%h/.ssh/authorized_keys|g' /etc/ssh/sshd_config
sed -i 's|PermitRootLogin without-password|PermitRootLogin yes|g' /etc/ssh/sshd_config
sed -i 's|#   IdentityFile ~/.ssh/id_rsa|IdentityFile ~/.ssh/id_rsa|g' /etc/ssh/ssh_config
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
