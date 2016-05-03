#!/bin/bash

service ssh start
asadmin start-domain

# Create Cluster
if [ -n "${DAS}" ]
then
  asadmin --user=admin --passwordfile=/opt/glassfishpwd --interactive=false create-cluster cluster1
  asadmin --user=admin stop-domain
  asadmin start-domain -v
fi
if [ -n "${DAS_PORT_4848_TCP_ADDR}" ]
then
  # Create cluster node
  asadmin --user=admin --passwordfile=/opt/glassfishpwd --interactive=false \
--host das --port 4848 create-local-instance --cluster cluster1 cluster1-"${HOSTNAME}"

  # Stop domain
  asadmin --user=admin stop-domain

  # Getting all keys from Domain Administration Server SSH
  ssh-keyscan -H das >> /root/.ssh/known_hosts

  # Busy waiting for SSH to be enabled
  SSH_STATUS=$(ssh root@das echo "I am waiting.")
  while [ "${SSH_STATUS}" = "ssh: connect to host das port 22: Connection refused" ]
  do
    sleep 20
    SSH_STATUS=$(ssh root@das echo "I am waiting.")
  done

  # Busy waiting for Domain Administration Server to be available
  DAS_STATUS=$(ssh root@das /glassfish4/glassfish/bin/asadmin --user=admin \
--passwordfile=/opt/glassfishpwd list-domains | head -n 1)

  while [ "${DAS_STATUS}" = "domain1 not running" ]
  do
    sleep 20
    DAS_STATUS=$(ssh root@das /glassfish4/glassfish/bin/asadmin --user=admin \
  --passwordfile=/opt/glassfishpwd list-domains | head -n 1)
  done

  # Get node own LAN IP
  NODEHOST_ENTRY=$(cat /etc/hosts | grep "${HOSTNAME}")
  export HOST_IP=$(echo "${NODEHOST_ENTRY}" | cut -f1 -s)
  if [ -z "${HOST_IP}" ]
    then export HOST_IP=$(echo "${NODEHOST_ENTRY}" | cut -d' ' -f1)
  fi

  # Update existing CONFIG node to a SSH one
  ssh root@das /glassfish4/glassfish/bin/asadmin --user=admin \
--passwordfile=/opt/glassfishpwd --interactive=false update-node-ssh \
--sshuser root --sshkeyfile /root/.ssh/id_rsa \
--nodehost "${HOST_IP}" --installdir /glassfish4 "${HOSTNAME}"

  # Start instance
  ssh root@das /glassfish4/glassfish/lib/nadmin --user=admin \
--passwordfile=/opt/glassfishpwd --interactive=false start-instance cluster1-"${HOSTNAME}"

  while [[ true ]]; do
    sleep 1
  done
fi
