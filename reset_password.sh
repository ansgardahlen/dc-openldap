#!/bin/sh
#
# This script will reset password of user fd-admin
#

source ./openldap.conf

echo "dn: uid=fd-admin,${LDAP_BASE_DN}
changetype: modify
replace: userPassword
userPassword: ${FD_ADMIN_PASSWORD}" | \
docker exec -i dc_openldap ldapmodify -h localhost -p 389 -D "cn=admin,${LDAP_BASE_DN}" -w ${LDAP_ADMIN_PASSWORD} 
#docker-compose exec openldap ldapmodify -h localhost -p 389 -D "cn=admin,${LDAP_BASE_DN}" -w ${LDAP_ADMIN_PASSWORD} 

