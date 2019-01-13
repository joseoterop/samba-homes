# SAMBA
## JOSE OTERO PEREZ ESCOLADELTREBALL ASIX 2019



### Incluye:

Modelo cliente - servidor de una server samba con un backend basado en ldap

### Etructura de los contenedores:

#### Necesitamos:

* Red compartida para los diferentes contenedores
* Servidor LDAP tuneado para admitir un schema samba
* Docker PAM para validar los usuarios ldap/unix/samba y montar el recurso compartido en su home.

  
#### Configuración del acceso:

* Usuarios UNIX:
  - Samba requiere que los usuarios existan, ya sean locales o ldap, para ello el servidor debe tener los demonios `nscd` y `nslcd` activos-

* Homes:
  - Los usuarios locales ya tienen un home asignado cuando se crean, para los usuarios no locales, este debe de ser creado y administrado de la forma adecuada.
   
* Usuarios SAMBA:
  - Para usar la orden `smbpasswd` los usuarios deben existir anteriormente, ya sean locales o de ldap.

* El hostpam:
   - En el servidor PAM debemos modificar el archivo `/etc/security/pam_mount.conf.xml` de cara a montar el recurso externo.

### Cofiguració del servidor samba-ldap:

Para el correcto funcionamiento del servidor, tenemos que asegurarnos que los siguientes pasos estan correctamente configurados.
	
  - Incluir el schema en el servidor LDAP
  - Instalar el paquete smbldap-tools en el servidor sambaldap.
  - Configurar correctament el servidor samba amb LDAP com a backend.
  - Editar `/etc/smbldap-tools/smbldap.conf` y `/etc/smbldap_bind.conf`.
  - Usar las ordenes  `net getlocalsid` i `net *getdomainsid` para cerciorarse del correcto funcionamiento del servidor.
  - Ejecutar el populate **smbldap-populate**.
  - Probar la conexió con ldap mediante `ldapsearch`.




### Ejecución:


```
docker network create sambanet

docker run --rm --name ldap --hostname ldap --network sambanet -d joterop/ldap-samba

docker run --rm --name host --hostname host --network sambanet --privileged -it joterop/host-pam

docker run --rm --name samba --hostname samba --network sambanet -- privileged -it joterop/ldapsam

```


### Ficheros samba:

/etc/samba/smb.conf
```
[global]
        workgroup = SAMBA
        security = user

        passdb backend = tdbsam

        printing = cups
        printcap name = cups
        load printers = yes
        cups options = raw

[homes]
        comment = Home Directories
        valid users = %S, %D%w%S
        browseable = No
        read only = No
        inherit acls = Yes

[printers]
        comment = All Printers
        path = /var/tmp
        printable = Yes
        create mask = 0600
        browseable = No

[print$]
        comment = Printer Drivers
        path = /var/lib/samba/drivers
        write list = @printadmin root
        force group = @printadmin
        create mask = 0664
        directory mask = 0775
```

/etc/smbldap-tools/smbldap.conf
  - slaveLDAP="ldap://172.19.0.2/"
  - masterLDAP="ldap://172.19.0.2/"
  - ldapTLS="0"
  - suffix="dc=edt,dc=org"
  - userdn="ou=usuaris,${suffix}"
  - computersdn="ou=hosts,${suffix}"
  - groupsdn="oi=grups,${suffix}"
  - idmapdn="ou=domains,${suffix}"
```

```

/etc/smbldap-tools/smbldap_bind.conf

```
# $Id$
#
############################
# Credential Configuration #
############################
# Notes: you can specify two differents configuration if you use a
# master ldap for writing access and a slave ldap server for reading access
# By default, we will use the same DN (so it will work for standard Samba
# release)
slaveDN="cn=Manager,dc=edt,dc=org"
slavePw="secret"
masterDN="cn=Manager,dc=edt,dc=org"
masterPw="secret"
~              
```
### Pruebas

```[root@samba docker]# net getdomainsid
SID for local machine SAMBA is: S-1-5-21-383218060-1901296601-3541469167
SID for domain SAMBA is: S-1-5-21-383218060-1901296601-3541469167

[root@samba docker]# net getlocalsid
SID for domain SAMBA is: S-1-5-21-383218060-1901296601-3541469167


[root@samba docker]# pdbedit -L
pla:1001:
rock:1003:
pere:5001:Pere Pou
patipla:1002:
lila:1000:
pau:5000:Pau Pou
marta:5003:Marta Mas
admin:10:Administrador Sistema

[root@samba docker]# ldapsearch -x -LLL 
...
dn: uid=root,ou=usuaris,dc=edt,dc=org
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: sambaSamAccount
objectClass: posixAccount
objectClass: shadowAccount
uid: root
cn: root
sn: root
gidNumber: 0
uidNumber: 0
homeDirectory: /home/root
sambaLogonTime: 0
sambaLogoffTime: 2147483647
sambaKickoffTime: 2147483647
sambaPwdCanChange: 0
sambaHomePath: \\PDC-SRV\root
sambaHomeDrive: H:
sambaProfilePath: \\PDC-SRV\profiles\root
sambaPrimaryGroupSID: S-1-5-21-2147421307-653842684-3480799070-512
sambaSID: S-1-5-21-2147421307-653842684-3480799070-500
loginShell: /bin/false
gecos: Netbios Domain Administrator
sambaNTPassword: 55F79BF273802801CFC79712AAC292F3
sambaPwdMustChange: 1551296827
sambaAcctFlags: [U]
sambaLMPassword: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
sambaPwdLastSet: 1547408827
userPassword:: e1NTSEF9ZWVuNkloMStJcjdFM2hXdHFGalZYRjA0enBWUmVIZ3Y=
shadowLastChange: 17909
shadowMax: 45

dn: uid=nobody,ou=usuaris,dc=edt,dc=org
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: sambaSamAccount
objectClass: posixAccount
objectClass: shadowAccount
cn: nobody
sn: nobody
gidNumber: 514
uid: nobody
uidNumber: 999
homeDirectory: /nonexistent
sambaPwdLastSet: 0
sambaLogonTime: 0
sambaLogoffTime: 2147483647
sambaKickoffTime: 2147483647
sambaPwdCanChange: 0
sambaPwdMustChange: 2147483647
sambaHomePath: \\PDC-SRV\nobody
sambaHomeDrive: H:
sambaProfilePath: \\PDC-SRV\profiles\nobody
sambaPrimaryGroupSID: S-1-5-21-2147421307-653842684-3480799070-514
sambaLMPassword: NO PASSWORDXXXXXXXXXXXXXXXXXXXXX
sambaNTPassword: NO PASSWORDXXXXXXXXXXXXXXXXXXXXX
sambaAcctFlags: [NUD        ]
sambaSID: S-1-5-21-2147421307-653842684-3480799070-501
loginShell: /bin/false

dn: cn=Domain Admins,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Domain Admins
gidNumber: 512
memberUid: root
description: Netbios Domain Administrators
sambaSID: S-1-5-21-2147421307-653842684-3480799070-512
sambaGroupType: 2
displayName: Domain Admins

dn: cn=Domain Users,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Domain Users
gidNumber: 513
description: Netbios Domain Users
sambaSID: S-1-5-21-2147421307-653842684-3480799070-513
sambaGroupType: 2
displayName: Domain Users

dn: cn=Domain Guests,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Domain Guests
gidNumber: 514
description: Netbios Domain Guests Users
sambaSID: S-1-5-21-2147421307-653842684-3480799070-514
sambaGroupType: 2
displayName: Domain Guests

dn: cn=Domain Computers,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Domain Computers
gidNumber: 515
description: Netbios Domain Computers accounts
sambaSID: S-1-5-21-2147421307-653842684-3480799070-515
sambaGroupType: 2
displayName: Domain Computers

dn: cn=Administrators,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Administrators
gidNumber: 544
description: Netbios Domain Members can fully administer the computer/sambaDom
 ainName
sambaSID: S-1-5-32-544
sambaGroupType: 4
displayName: Administrators

dn: cn=Account Operators,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Account Operators
gidNumber: 548
description: Netbios Domain Users to manipulate users accounts
sambaSID: S-1-5-32-548
sambaGroupType: 4
displayName: Account Operators

dn: cn=Print Operators,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Print Operators
gidNumber: 550
description: Netbios Domain Print Operators
sambaSID: S-1-5-32-550
sambaGroupType: 4
displayName: Print Operators

dn: cn=Backup Operators,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Backup Operators
gidNumber: 551
description: Netbios Domain Members can bypass file security to back up files
sambaSID: S-1-5-32-551
sambaGroupType: 4
displayName: Backup Operators

dn: cn=Replicators,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Replicators
gidNumber: 552
description: Netbios Domain Supports file replication in a sambaDomainName
sambaSID: S-1-5-32-552
sambaGroupType: 4
displayName: Replicators

```



