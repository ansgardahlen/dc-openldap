#!/bin/bash

if [[ -f openldap.conf ]]; then
  read -r -p "config file openldap.conf exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv openldap.conf checkmk.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi


if [ -z "$LDAP_ORGANISATION" ]; then
  read -p "ORGANISATION NAME: " -ei "Example" LDAP_ORGANISATION
fi

if [ -z "$LDAP_DOMAIN" ]; then
  read -p "LDAP Domain NAME: " -ei "example.org" LDAP_DOMAIN
fi

if [ -z "$LDAP_BASE_DN" ]; then
  read -p "LDAP BASE DN: " -ei "dc=example,dc=org" LDAP_BASE_DN
fi

if [ -z "$PUBLIC_FQDN" ]; then
  read -p "Hostname (FQDN): " -ei "example.org" PUBLIC_FQDN
fi

if [ -z "$ADMIN_MAIL" ]; then
  read -p "CheckMK admin Mail address: " -ei "mail@example.com" ADMIN_MAIL
fi

[[ -f /etc/timezone ]] && TZ=$(cat /etc/timezone)
if [ -z "$TZ" ]; then
  read -p "Timezone: " -ei "Europe/Berlin" TZ
fi

cat << EOF > openldap.conf
# ------------------------------
# openldap.conf web ui configuration
# ------------------------------
# example.org is _not_ a valid hostname, use a fqdn here.
PUBLIC_FQDN=${PUBLIC_FQDN}

# ------------------------------
# OPENLADP admin user
# ------------------------------
OPENLADP_ADMIN=ldapadmin
ADMIN_MAIL=${ADMIN_MAIL}
OPENLADP_PASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

# ------------------------------
# Bindings
# ------------------------------

# You should use HTTPS, but in case of SSL offloaded reverse proxies:
HTTP_PORT=80
HTTP_BIND=0.0.0.0

# Your timezone
TZ=${TZ}

# Fixed project name
COMPOSE_PROJECT_NAME=openldap

LDAP_ORGANISATION=${LDAP_ORGANISATION}
LDAP_DOMAIN=${LDAP_DOMAIN}
LDAP_BASE_DN=${LDAP_BASE_DN}
LDAP_ADMIN_PASSWORD=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
LDAP_CONFIG_PASSWORD=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
LDAP_READONLY_USER=false
LDAP_READONLY_USER_USERNAME=reader
LDAP_READONLY_USER_PASSWORD=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
LDAP_RFC2307BIS_SCHEMA=false
LDAP_BACKEND=hdb
LDAP_TLS=true
LDAP_TLS_CRT_FILENAME=ldap.crt
LDAP_TLS_KEY_FILENAME=ldap.key
LDAP_TLS_CA_CRT_FILENAME=ca.crt
LDAP_TLS_ENFORCE=false
LDAP_TLS_CIPHER_SUITE=SECURE256:-VERS-SSL3.0
LDAP_TLS_PROTOCOL_MIN=3.1
LDAP_TLS_VERIFY_CLIENT=demand
LDAP_REPLICATION=false
#LDAP_REPLICATION_CONFIG_SYNCPROV="binddn="cn=admin,cn=config" bindmethod=simple credentials=$LDAP_CONFIG_PASSWORD searchbase="cn=config" type=refreshAndPersist retry="60 +" timeout=1 starttls=critical"
#LDAP_REPLICATION_DB_SYNCPROV="binddn="cn=admin,$LDAP_BASE_DN" bindmethod=simple credentials=$LDAP_ADMIN_PASSWORD searchbase="$LDAP_BASE_DN" type=refreshAndPersist interval=00:00:00:10 retry="60 +" timeout=1 starttls=critical"
#LDAP_REPLICATION_HOSTS="#PYTHON2BASH:['ldap://ldap.example.org','ldap://ldap2.example.org']"
KEEP_EXISTING_CONFIG=false
LDAP_REMOVE_CONFIG_AFTER_SETUP=true
LDAP_SSL_HELPER_PREFIX=ldap
FD_ADMIN_PASSWORD=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

EOF

