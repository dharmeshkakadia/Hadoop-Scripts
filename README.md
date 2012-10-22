Hadoop-Scripts
==============

Few hack scripts related to hadoop

1) hadoop_install.sh installs and configures hadoop on a cluster. The idea is to create a hadoop cluster hassle-free.
Syntax: ./hadoop_install Hadoop_download_URL Cluster_properties

2) ssh-id-copy.sh script is used to copy the ssh id of jobtracker to all slave machines. The intention is to provide passwordless access to all slave machines from the jobtracker.

Syntax: ./ssh-id-copy location_of_identity_file location_of_properties_file


