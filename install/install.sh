#!/bin/bash

# Install OpenJDK 8 and some packages to removed later
echo 'deb http://httpredir.debian.org/debian jessie-backports main' > \
/etc/apt/sources.list.d/jessie-backports.list
apt-get -qq update
apt-get install -yqq wget unzip openjdk-8-jdk openssh-server

# Install Glassfish Application Server
wget --quiet --no-check-certificate $GLASSFISH_URL
echo "$MD5 *$GLASSFISH_PKG" | md5sum -c -
unzip -o $GLASSFISH_PKG
rm -f $GLASSFISH_PKG
apt-get purge -yqq wget unzip && rm -rf /var/cache/apt/*
echo "AS_ADMIN_PASSWORD=" > /tmp/glassfishpwd

# Change Glassfish default user password
echo "AS_ADMIN_NEWPASSWORD=${PASSWORD}" >> /tmp/glassfishpwd
asadmin --user=admin --passwordfile=/tmp/glassfishpwd change-admin-password --domain_name domain1

# Enable secure admin
asadmin start-domain
echo "AS_ADMIN_PASSWORD=${PASSWORD}" > /tmp/glassfishpwd
asadmin --user=admin --passwordfile=/tmp/glassfishpwd enable-secure-admin

asadmin --user=admin stop-domain

# Configure SSH
echo 'root:glassfish' | chpasswd
sed -i 's|#PubkeyAuthentication yes|PubkeyAuthentication yes|g' /etc/ssh/sshd_config
sed -i 's|#StrictModes yes|StrictModes yes|g' /etc/ssh/sshd_config
sed -i 's|#AuthorizedKeysFile	%h/.ssh/authorized_keys|AuthorizedKeysFile	%h/.ssh/authorized_keys|g' /etc/ssh/sshd_config
sed -i 's|PermitRootLogin without-password|PermitRootLogin yes|g' /etc/ssh/sshd_config
sed -i 's|#   IdentityFile ~/.ssh/id_rsa|IdentityFile ~/.ssh/id_rsa|g' /etc/ssh/ssh_config
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
