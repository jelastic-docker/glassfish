# Install Glassfish Application Server
wget --quiet --no-check-certificate $GLASSFISH_URL
#echo "$MD5 *$GLASSFISH_PKG" | md5sum -c -
unzip -o $GLASSFISH_PKG

echo "AS_ADMIN_PASSWORD=" > ~/glassfishpwd

# Change Glassfish default user password
echo "AS_ADMIN_NEWPASSWORD=${PASSWORD}" >> ~/glassfishpwd
~/glassfish4/bin/asadmin --user=admin --passwordfile=~/glassfishpwd change-admin-password --domain_name domain1

# Enable secure admin
~/glassfish4/bin/asadmin start-domain
echo "AS_ADMIN_PASSWORD=${PASSWORD}" > ~/glassfishpwd
~/glassfish4/bin/asadmin --user=admin --passwordfile=~/glassfishpwd enable-secure-admin

~/glassfish4/bin/asadmin --user=admin stop-domain