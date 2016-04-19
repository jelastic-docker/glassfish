FROM debian:jessie
MAINTAINER "Andre Tadeu de Carvalho <andre.tadeu.de.carvalho@gmail.com>"

ENV GLASSFISH_PKG=glassfish-4.1.1.zip \
    GLASSFISH_URL=http://download.oracle.com/glassfish/4.1.1/release/glassfish-4.1.1.zip \
    GLASSFISH_HOME=/glassfish4 \
    MD5=4e7ce65489347960e9797d2161e0ada2 \
    PATH=$PATH:/glassfish4/bin \
    PASSWORD=glassfish \
    JAVA_HOME=/usr/lib/jvm/java-openjdk

COPY install/install.sh /tmp/install.sh
RUN chmod 755 /tmp/install.sh
RUN tmp/install.sh

# Ports being exposed
EXPOSE 22 3700 4848 7676 8080 8181 8686

# Start asadmin console and the domain
CMD ["asadmin", "start-domain", "-v"]
