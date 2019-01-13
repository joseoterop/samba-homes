
#! /bin/bash
# @edt ASIX M06 2018-2019
# instal.lacio
#  - samba config backend ldap
# -------------------------------------
cp /opt/docker/smbldap.conf /etc/smbldap-tools/.
cp /opt/docker/smbldap_bind.conf /etc/smbldap-tools/.

echo -e "jupiter\njupiter" | smbldap-populate

