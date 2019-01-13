### JOSE OTERO PEREZ ESCOLADELTREBALL ASIX 2019


Proyecto para realizar mediante una estructura docker un servidor que exporta resources mediante samba con un backend basado en ldap.


#### RUN

```
docker run --rm --name ldap --hostname ldap --network sambanet -d joterop/ldap-samba

docker run --rm --name host --hostname host --network sambanet --privileged -it joterop/host-pam

docker run --rm --name samba --hostname samba --network sambanet -- privileged -it joterop/ldapsam

```


