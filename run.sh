#!/bin/bash

start() {
    service ssh start
    /glassfish4/bin/asadmin start-domain

    # Create Cluster
    if [ -n "${DAS}" ]
    then
        /glassfish4/bin/asadmin --user=admin --passwordfile=/opt/glassfishpwd --interactive=false create-cluster cluster1
        /glassfish4/bin/asadmin --user=admin stop-domain
        /glassfish4/bin/asadmin start-domain -v
    fi
    if [ -n "${DAS_PORT_4848_TCP_ADDR}" ]
    then
        # Create cluster node
        /glassfish4/bin/asadmin --user=admin --passwordfile=/opt/glassfishpwd --interactive=false \
        --host das --port 4848 create-local-instance --cluster cluster1 cluster1-"${HOSTNAME}"

        # Stop domain
        /glassfish4/bin/asadmin --user=admin stop-domain

        # Getting all keys from Domain Administration Server SSH
        ssh-keyscan -H das >> /root/.ssh/known_hosts

        # Busy waiting for SSH to be enabled
        SSH_STATUS=$(ssh root@das echo "I am waiting.")
        echo $SSH_STATUS >> /var/log/run.log
        while [ "${SSH_STATUS}" = "ssh: connect to host das port 22: Connection refused" || "${SSH_STATUS}" = "Host key verification failed."]
        do
            sleep 20
            SSH_STATUS=$(ssh root@das echo "I am waiting.")
            echo $SSH_STATUS >> /var/log/run.log
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
}

stop() {
    ssh root@das /glassfish4/glassfish/lib/nadmin --user=admin \
    --passwordfile=/opt/glassfishpwd --interactive=false stop-instance cluster1-"${HOSTNAME}"

    ssh root@das /glassfish4/glassfish/lib/nadmin --user=admin \
    --passwordfile=/opt/glassfishpwd --interactive=false delete-instance cluster1-"${HOSTNAME}"

    ssh root@das /glassfish4/glassfish/bin/asadmin --user=admin \
    --passwordfile=/opt/glassfishpwd --interactive=false delete-node-ssh "${HOSTNAME}"

    /glassfish4/glassfish/lib/nadmin --user=admin --passwordfile=/opt/glassfishpwd \
    --interactive=false delete-local-instance --node "${HOSTNAME}" cluster1-"${HOSTNAME}"
}

case ${1} in
    gf:start)
        start
        ;;
    gf:stop)
        stop
        ;;
esac
