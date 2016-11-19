FROM debian:jessie
MAINTAINER "info@jelastic.com"

ARG GLASSFISH_VERSION=4.1.1
ARG GLASSFISH_PKG=glassfish-${GLASSFISH_VERSION}.zip
ARG GLASSFISH_URL=http://download.oracle.com/glassfish/${GLASSFISH_VERSION}/release/${GLASSFISH_PKG}
ARG MD5=4e7ce65489347960e9797d2161e0ada2
ARG PASSWORD=glassfish
ARG JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

COPY install/install.sh /tmp/install.sh
RUN chmod 755 /tmp/install.sh
RUN tmp/install.sh

COPY run.sh /run.sh
RUN chmod 755 /run.sh

# Ports being exposed
EXPOSE 22 3700 4848 7676 8080 8181 8686

# Start asadmin console and the domain
CMD ["./run.sh", "gf:start"]
