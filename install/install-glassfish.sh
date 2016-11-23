# Install Glassfish Application Server
wget --quiet --no-check-certificate $GLASSFISH_URL -O ~/$GLASSFISH_PKG
echo "$MD5 *$GLASSFISH_PKG" | md5sum -c -
unzip -o ~/$GLASSFISH_PKG
rm -f ~/$GLASSFISH_PKG

echo "AS_ADMIN_PASSWORD=" > ${PSWD_FILE}

# Change Glassfish default user password
echo "AS_ADMIN_NEWPASSWORD=${PASSWORD}" >> ${PSWD_FILE}
~/glassfish4/bin/asadmin --user=admin --passwordfile=${PSWD_FILE} change-admin-password --domain_name domain1

# Enable secure admin
~/glassfish4/bin/asadmin start-domain
echo "AS_ADMIN_PASSWORD=${PASSWORD}" > ${PSWD_FILE}
~/glassfish4/bin/asadmin --user=admin --passwordfile=${PSWD_FILE} enable-secure-admin

~/glassfish4/bin/asadmin --user=admin stop-domain