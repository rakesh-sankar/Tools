#!/bin/sh

user=$1
apache="www-data"
developers="developers"
passuser="${user}!@34"
newpasswd=$(perl -e 'print crypt($ARGV[0], "cOStr@teg1x")' $passuser)
createuser='/usr/sbin/useradd'
modifyuser='/usr/sbin/usermod'

##create and update password, then assign the apache group to the user
$createuser -d /home/$user -g $apache -m -s /bin/bash -p $newpasswd $user

#modify the user
$modifyuser -aG $developers $user

#create the ssk-key
#To get this working do the following:
#1. Create a different key-pair from AWS console & store the private key
#2. Now generate the public key somewhere and copy this over /home/<user>/.ssh/authorized_keys
#copy the existing key from root and use it for all
#pubkey='/home/rakesh/.ssh/authorized_keys'

#copy the authorized-keys to the user
