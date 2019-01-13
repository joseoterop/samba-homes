#! /bin/bash
# @edt ASIX M06 2018-2019
# instal·lacio slapd edt.org
# -------------------------------------------
rm -rf /etc/openldap/slapd.d/*
rm -rf /var/lib/ldap/*
cp /opt/docker/DB_CONFIG /var/lib/ldap
cp /opt/docker/joseSAMBA.schema /etc/openldap/schema/joseSAMBA.schema
cp /opt/docker/ldap.conf /etc/openldap/ldap.conf
slaptest -F /etc/openldap/slapd.d/ -f /opt/docker/slapd.conf
slapadd	-F /etc/openldap/slapd.d/ -l /opt/docker/edt.ldif
chown -R ldap.ldap /var/lib/ldap
chown -R ldap.ldap /etc/openldap/slapd.d

