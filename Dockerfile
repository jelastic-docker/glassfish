FROM debian:jessie
MAINTAINER "info@jelastic.com"

ARG GLASSFISH_VERSION=4.1.1
ARG GLASSFISH_PKG=glassfish-${GLASSFISH_VERSION}.zip
ARG GLASSFISH_URL=http://download.oracle.com/glassfish/${GLASSFISH_VERSION}/release/${GLASSFISH_PKG}
ARG MD5=4e7ce65489347960e9797d2161e0ada2
ARG PASSWORD=glassfish
ARG JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV USER glassfish

RUN useradd -m -d /home/"${USER}" "${USER}"
RUN chsh -s /bin/bash "${USER}"

COPY install/install.sh /install.sh
RUN chmod 755 /install.sh
RUN /install.sh

COPY install/install-glassfish.sh /install-glassfish.sh
RUN chmod 755 /install-glassfish.sh
USER $USER 
WORKDIR /home/$USER
RUN pwd
RUN ls -l /home
RUN ls -l ~/
RUN /install-glassfish.sh
USER root

#RUN apt-get purge -yqq wget unzip && rm -rf /var/cache/apt/*

COPY glassfish.sh /glassfish.sh
RUN chmod 755 /glassfish.sh

COPY run.sh /run.sh
RUN chmod 755 /run.sh

# Ports being exposed
EXPOSE 22 3700 4848 7676 8080 8181 8686

# Start asadmin console and the domain
#CMD ["./run.sh", "gf:start"]
