#! /bin/bash
# @edt ASIX M06 2018-2019
# instal.lacio
#  - samba
# -------------------------------------

mkdir -p /tmp/home/pere
mkdir -p /tmp/home/pau
mkdir -p /tmp/home/marta
mkdir -p /tmp/home/anna
mkdir -p /tmp/home/admin

chown -R 5001.100 /tmp/home/pere
chown -R 5000.100 /tmp/home/pau
chown -R 5003.100 /tmp/home/marta
chown -R 5002.100 /tmp/home/anna
chown -R admin.wheel /tmp/home/admin

