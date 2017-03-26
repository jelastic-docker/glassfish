#!/bin/bash

# Install OpenJDK 8 and some packages to removed later
echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
apt-get -qq update
apt-get install -yqq wget unzip openjdk-8-jdk openssh-server
