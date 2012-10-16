#!/bin/bash

# This script takes two arguments
# Arguments:
# * Location of identity(.pem) file
# * Location of properties file(This will give me system IPs)
# Assumption: This script will be executed in jobtracker. This is considering that ssh trust is only required between jobtracker<->slaves and its one way.

identity_file=$1
properties_file=$2
user="root"

#jobtracker=`cat $properties_file | grep -i jobtracker | cut -f 2 | cut -d ":" -f 1`

slaves=`cat $properties_file | grep -i slave | cut -f 2`

# Here we check if a keypair already exists in the default location. If not, we create one.
if [ ! -e ~/.ssh/id_rsa ]
then
	 ssh-keygen -f ~/.ssh/id_rsa -P ""
fi

for slave in $slaves
do
	ssh-copy-id -i $identity_file $user@$slave
done
