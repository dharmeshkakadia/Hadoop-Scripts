#!/bin/bash
# adds a node in a running hadoop cluster
# takes first argument as the ip_address/name of the node to be added

cd /usr/local/hadoop/conf
echo $1 >> slaves

# copy hadoop
rsync -vaz --exclude='logs/*' /usr/local/hadoop $1:/usr/local/

#refresh nodelist
../bin/hadoop dfsadmin -refreshNodes
../bin/hadoop mradmin -refreshNodes

# start the daemons
ssh $1 "/usr/local/hadoop/bin/hadoop-daemon.sh start datanode"
ssh $1 "/usr/local/hadoop/bin/hadoop-daemon.sh start tasktracker"

# verify
ssh $1 "jps"
