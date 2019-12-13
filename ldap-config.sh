#!/bin/bash

LDAPATH="$HOME/LDAP"
if [ ! -d $HOME/LDAP/ ];then
	mkdir $HOME/LDAP
fi

function AddUser {
	read -p "Nombre de usuario (uid): " uid
	read -p "Nombre completo del usuario: " cnsn
	read -p "Nombre Unidad Organizativa: " ou
	read -p "Nombre del dominio: " dc
	read -p "uidNumber: " uidNumber
	read -p "gidNumber: " gidNumber
	read -s -p "Contraseña del usuario: " password
	echo ""
	cn=$(echo $cnsn | cut -d " " -f1)
	sn=$(echo $cnsn | cut -d " " -f2)
        dc1=$(echo $dc | cut -d "." -f1)
        dc2=$(echo $dc | cut -d "." -f2)
	hash_password=$(slappasswd -d $password)
	#hash_password=$(echo $password | md5sum)
	
	cat <<EOF >> ${LDAPATH}/usuario.ldif
dn: uid=$uid,ou=$ou,dc=$dc1,dc=$dc2
objectClass: top 
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: person
cn: $cn
sn: $sn
uid: $uid
uidNumber: $uidNumber
gidNumber: $gidNumber
homeDirectory: /home/${cn}${sn}
loginShell: /bin/bash
userPassword: $hash_password
givenName: $cn

EOF
echo
echo "Archivo usuario.ldif guardado en $LDAPATH"

}

function AddGroup {
	read -p "Nombre del grupo: " cn
        read -p "Unidad Organizativa: " ou
        read -p "Nombre del dominio: " dc
        read -p "ID del grupo: " gidNumber
        dc1=$(echo $dc | cut -d "." -f1)
        dc2=$(echo $dc | cut -d "." -f2)

        cat <<EOF >> ${LDAPATH}/grupos.ldif
dn: cn=$cn,ou=$ou,dc=$dc1,dc=$dc2
objectClass: top
objectClass: posixGroup
gidNumber: $gidNumber
cn: $cn

EOF
echo
echo "Archivo grupos.ldif guardado en $LDAPATH"
}

function AddOU {
        read -p "Unidad Organizativa: " ou
        read -p "Nombre del dominio: " dc
        dc1=$(echo $dc | cut -d "." -f1)
        dc2=$(echo $dc | cut -d "." -f2)

        cat <<EOF >> ${LDAPATH}/unidadesorganizativas.ldif
dn: ou=$ou,dc=$dc1,dc=$dc2
objectClass: top
objectClass: organizationalUnit
ou: $ou

EOF
echo
echo "Archivo unidadesorganizativas.ldif guardado en $LDAPATH"
}

InMenu=true
while $InMenu;do
        echo -e "[1] Crear un Usuario"
        echo -e "[2] Crear un Grupo"
        echo -e "[3] Crear un UO"
	echo -e "[e] Salir"
        read -p "Elige una opcion: " opcion
        case $opcion in
                1)
                        AddUser
			;;
                2)
                        AddGroup
			;;
                3)
                        AddOU
			;;
		e|E)
			exit 0;;

                *)
			echo "Opciones 1-3; (e)xit";;
        esac
done
