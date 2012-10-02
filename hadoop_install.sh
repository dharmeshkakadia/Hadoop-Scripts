#!/bin/bash

# To Do
# Install Dependdencies like java, ssh etc

# Download and move hadoop
wget $1
echo "wget done"
tar xzf hadoop-*
rm hadoop-*.tar.gz
sudo rm -rf /usr/local/hadoop
sudo mv hadoop-* /usr/local/hadoop
#sudo chown -R hduser:hadoop /usr/local/hadoop

hadoop_masters=/usr/local/hadoop/conf/masters
hadoop_slaves=/usr/local/hadoop/conf/slaves
servers="$(cat $hadoop_masters $hadoop_slaves)"
JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk-amd64

# configure
sudo rm -rf /app/hadoop/tmp
sudo mkdir -p /app/hadoop/tmp
#sudo chown hduser:hadoop /app/hadoop/tmp

#mv /usr/local/hadoop/conf/hadoop-env.sh /usr/local/hadoop/conf/hadoop-env.sh.backup
cd /usr/local/hadoop/conf/

# master and slave files
echo `grep -i jobtracker $2 | cut -f 2 | cut -d ":" -f 1` > masters
echo `grep -i slave $2 | cut -f 2` > slaves

echo "export JAVA_HOME=$JAVA_HOME" >> hadoop-env.sh
#core-site.xml
echo -e "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
  <name>hadoop.tmp.dir</name>
  <value>/app/hadoop/tmp</value>
  <description>A base for other temporary directories.</description>
</property>

<property>
  <name>fs.default.name</name>
  <value>hdfs://`grep -i namenode $2 | cut -f 2`</value>
  <description>The name of the default file system.  A URI whose
  scheme and authority determine the FileSystem implementation.  The
  uri's scheme determines the config property (fs.SCHEME.impl) naming
  the FileSystem implementation class.  The uri's authority is used to
  determine the host, port, etc. for a filesystem.</description>
</property>
</configuration>" > core-site.xml

echo -e "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
  <name>mapred.job.tracker</name>
  <value>`grep -i jobtracker $2 | cut -f 2`</value>
  <description>The host and port that the MapReduce job tracker runs </description>
</property>
</configuration>" > mapred-site.xml

# hdfs-site.xml
echo -e "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
  <name>dfs.replication</name>
  <value>2</value>
  <description>Default block replication.
  The actual number of replications can be specified when the file is created.
  The default is used if replication is not specified in create time.
  </description>
</property>
</configuration>" > hdfs-site.xml

# rsync to slaves
for srv in $(cat $hadoop_slaves); do
  echo "Sending command to $srv..."; 
  rsync -vaz --exclude='logs/*' /usr/local/hadoop $srv:/usr/local/
  #ssh $srv "rm -fR /usr/local/$2 ; ln -s /usr/local/hadoop /usr/local/$"
done

# format namenode
cd /usr/local/hadoop/bin/
./hadoop namenode -format
./start-dfs.sh
./start-mapred.sh

# verify
for srv in $servers; do
  echo "Sending command to $srv..."; 
  ssh $srv "ps aux | grep -v grep | grep java"
done

echo "done."

