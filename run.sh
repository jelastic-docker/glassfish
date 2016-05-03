#!/bin/bash

service ssh start
asadmin start-domain
if ! [ -e /tmp/glassfishpwd ]
then
  echo "AS_ADMIN_PASSWORD=glassfish" > /tmp/glassfishpwd
fi

# Create Cluster
if [ -n "${DAS}" ]
then
  asadmin --user=admin --passwordfile=/tmp/glassfishpwd --interactive=false create-cluster cluster1
  asadmin --user=admin stop-domain
  asadmin start-domain -v
fi
if [ -n "${DAS_PORT_4848_TCP_ADDR}" ]
then
  # Create cluster node
  asadmin --user=admin --passwordfile=/tmp/glassfishpwd --interactive=false \
--host das --port 4848 create-local-instance --cluster cluster1 cluster1-"${HOSTNAME}"

  # Stop domain
  asadmin --user=admin stop-domain

  ssh-keyscan -H das >> /root/.ssh/known_hosts

  DAS_STATUS=$(ssh root@das /glassfish4/glassfish/bin/asadmin --user=admin \
--passwordfile=/tmp/glassfishpwd list-domains | head -n 1)

  while [ "${DAS_STATUS}" = "domain1 not running" ]
  do
    sleep 20
    DAS_STATUS=$(ssh root@das /glassfish4/glassfish/bin/asadmin --user=admin \
  --passwordfile=/tmp/glassfishpwd list-domains | head -n 1)
  done

  # Update existing CONFIG node to a SSH one
  ssh root@das /glassfish4/glassfish/bin/asadmin --user=admin \
--passwordfile=/tmp/glassfishpwd --interactive=false update-node-ssh \
--sshuser root --sshkeyfile /root/.ssh/id_rsa \
--nodehost $(cat /etc/hosts | grep "${HOSTNAME}" | cut -f1 -s) \
--installdir /glassfish4 "${HOSTNAME}"

  # Start instance
  ssh root@das /glassfish4/glassfish/lib/nadmin --user=admin \
--passwordfile=/tmp/glassfishpwd --interactive=false start-instance cluster1-"${HOSTNAME}"

  while [[ true ]]; do
    sleep 1
  done
fi
