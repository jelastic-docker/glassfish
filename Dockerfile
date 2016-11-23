FROM debian:jessie
MAINTAINER "info@jelastic.com"

ARG GLASSFISH_VERSION=4.1.1
ARG GLASSFISH_PKG=glassfish-${GLASSFISH_VERSION}.zip
ARG GLASSFISH_URL=http://download.oracle.com/glassfish/${GLASSFISH_VERSION}/release/${GLASSFISH_PKG}
ARG MD5=4e7ce65489347960e9797d2161e0ada2
ARG PASSWORD=glassfish
ARG JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV USER glassfish
ENV HOME_DIR /home/$USER
ENV PSWD_FILE $HOME_DIR/glassfishpwd

RUN useradd -m -d "${HOME_DIR}" -s /bin/bash "${USER}"

COPY install/install-root.sh /install-root.sh
RUN bash /install-root.sh

#COPY run.sh /run.sh
#RUN chmod 755 /run.sh

USER $USER 
WORKDIR $HOME_DIR

COPY install/install-glassfish.sh $HOME_DIR/install-glassfish.sh
RUN bash $HOME_DIR/install-glassfish.sh

COPY glassfish.sh $HOME_DIR/glassfish.sh

RUN mkdir $HOME_DIR/.ssh  

# Ports being exposed
EXPOSE 22 3700 4848 7676 8080 8181 8686

# Start asadmin console and the domain
CMD ["bash glassfish.sh", "start"]
