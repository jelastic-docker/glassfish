FROM debian:jessie
MAINTAINER "Andre Tadeu de Carvalho <andre.tadeu.de.carvalho@gmail.com>"

ARG GLASSFISH_VERSION=4.1.1
ARG GLASSFISH_PKG=glassfish-${GLASSFISH_VERSION}.zip
ARG GLASSFISH_URL=http://download.oracle.com/glassfish/${GLASSFISH_VERSION}/release/${GLASSFISH_PKG}
ARG MD5=4e7ce65489347960e9797d2161e0ada2
ARG PASSWORD=glassfish
ARG JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

COPY install/install.sh /tmp/install.sh
RUN chmod 755 /tmp/install.sh
RUN tmp/install.sh

RUN ssh-keygen  -t rsa -b 4096 -q -N '' -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

COPY run.sh /run.sh
RUN chmod 755 /run.sh

# Ports being exposed
EXPOSE 22 3700 4848 7676 8080 8181 8686

# Start asadmin console and the domain
CMD ["./run.sh", "gf:start"]
