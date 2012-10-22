#!/bin/bash
# adds a node in a running hadoop cluster
# Run this script on Master
# takes first argument as the ip_address/name of the node to be added

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 Node_IP" >&2
  exit 1
fi

# Node reachable ?
echo "Checking connectivity to the node..."
ping $1

if [ "$?" -ne 0 ]; then
  echo "Ping to the node $1 Failed. Check the node connectivity and try again" >&2
  exit 1
fi

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
