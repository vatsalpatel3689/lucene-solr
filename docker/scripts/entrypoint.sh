#!/bin/bash

#Run the install at runtime not at the docker build time to avoid the dependency of cryptex key at the build time
apt-get install --yes --allow-unauthenticated fk-neo-solr
cp /usr/local/bin/managed-schema /opt/fk-neo-solr/server/solr/configsets/banners/stage/conf/
#Creation of chroot path
/opt/fk-neo-solr/bin/solr zk mkroot /docker-solr-a -z zookeeper:2181

#upload config
/opt/fk-neo-solr/bin/solr zk upconfig -z zookeeper:2181/docker-solr-a -n banners -d /opt/fk-neo-solr/server/solr/configsets/banners/stage/

#start solr server
/etc/init.d/fk-neo-solr start
/etc/init.d/fk-neo-solr status

#Create collection
curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=banners&collection.configName=banners&numShards=1&replicationFactor=1&maxShardsPerNode=1&async=1000"

#Sleep the container for infinite duration to avoid container exit after solr start
sleep infinity