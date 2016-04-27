#!/bin/bash

asadmin start-domain
# Create Cluster
if [ -n "${DAS}" ]
then
  asadmin --user=admin --passwordfile=/tmp/glassfishpwd --interactive=false create-cluster cluster1
fi
asadmin --user=admin stop-domain

service ssh start
asadmin start-domain -v
