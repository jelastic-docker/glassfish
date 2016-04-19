#!/bin/bash

echo 'deb http://httpredir.debian.org/debian jessie-backports main' > \
/etc/apt/sources.list.d/jessie-backports.list
apt-get -qq update
apt-get install -yqq wget unzip openjdk-8-jdk openssh-server
wget --quiet --no-check-certificate $GLASSFISH_URL
echo "$MD5 *$GLASSFISH_PKG" | md5sum -c -
unzip -o $GLASSFISH_PKG
rm -f $GLASSFISH_PKG
apt-get purge -yqq wget unzip && rm -rf /var/cache/yum/*
echo "AS_ADMIN_PASSWORD=" > /tmp/glassfishpwd
echo "AS_ADMIN_NEWPASSWORD=${PASSWORD}" >> /tmp/glassfishpwd
asadmin --user=admin --passwordfile=/tmp/glassfishpwd change-admin-password --domain_name domain1
asadmin start-domain
echo "AS_ADMIN_PASSWORD=${PASSWORD}" > /tmp/glassfishpwd
asadmin --user=admin --passwordfile=/tmp/glassfishpwd enable-secure-admin
asadmin --user=admin stop-domain
rm /tmp/glassfishpwd
sed -i 's|#PubkeyAuthentication yes|PubkeyAuthentication yes|g' /etc/ssh/sshd_config
sed -i 's|#StrictModes yes|StrictModes yes|g' /etc/ssh/sshd_config
