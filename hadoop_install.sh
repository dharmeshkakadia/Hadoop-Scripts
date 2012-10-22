!/bin/bash
# Downloads and configures hadoop on cluster.
# To Do
# Install Dependdencies like java, ssh etc
# takes two arguments
#       $1 is URL to download the hadoop tar
#       $2 is properties file which gives the cluster parameters (see the example Properties file)

# Argument check
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 URL Cluster_properties_file" >&2
  exit 1
fi

# Download and move hadoop
wget $1
tar xzf hadoop-*
rm hadoop-*.tar.gz
sudo rm -rf /usr/local/hadoop
sudo mv hadoop-* /usr/local/hadoop
#sudo chown -R hduser:hadoop /usr/local/hadoop

# configure
echo "-----------starting configuration-------------"
sudo rm -rf /app/hadoop/tmp
sudo mkdir -p /app/hadoop/tmp

cd /usr/local/hadoop/conf/
# actually not needed, used by start-all.sh and stop-all.sh
# master and slave files
grep -i jobtracker $2 | cut -f 2 | cut -d ":" -f 1 > masters
grep -i slave $2 | cut -f 2 > slaves

# change JAVA_HOME according to your environment
JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk-amd64
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
for srv in $(cat /usr/local/hadoop/conf/slaves); do
  echo "Sending command to $srv...";
  rsync -vaz --exclude='logs/*' /usr/local/hadoop $srv:/usr/local/
  ssh $srv "rm -fR /app"
done

# All the nodes in the cluster
servers="$(cat masters slaves)"

echo "-----------starting hadoop cluster-------------"
# format namenode
cd /usr/local/hadoop/bin/
./hadoop namenode -format
./start-dfs.sh
./start-mapred.sh

echo "-----------Verfing hadoop daemons-------------"
# verify
for srv in $servers; do
  echo "Running jps on $srv.........";
#  ssh $srv "ps aux | grep -v grep | grep java"
  ssh $srv "jps"
done

echo "done!!!!!!"