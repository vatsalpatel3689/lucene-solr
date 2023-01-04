FROM 10.47.7.214/base-image:latest

ARG VERSION

ADD docker/scripts/entrypoint.sh /usr/local/bin/
ADD docker/config/fk-neo-solr.in.sh /etc/default/

#Making the required directories for cryptex
RUN mkdir -p /etc/vault/

#Setting up the pre-requisite packages for the solr
RUN apt-get install daemontools
RUN apt-get install daemontools-run
RUN apt-get install sudo

#clear out source files
RUN > /etc/apt/sources.list
RUN rm -rf /etc/apt/sources.list.d/*

#Configuring solr environment
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN echo "test" > /etc/default/fk-neo-solr-env
RUN echo "host=10.47.0.101" > /etc/default/cfg-api

#Updating the apt with infra cli and solr package
RUN echo "deb [trusted=yes] http://10.47.4.220/repos/infra-cli/7 /" > /etc/apt/sources.list.d/infra-cli.list
RUN apt-get update
RUN apt-get install --yes --allow-unauthenticated infra-cli

# install deployment tools
#RUN reposervice --host 10.24.0.41 --port 8080 env --name fk-neo-solr-debian-stretch --appkey test --version $VERSION | tee /etc/apt/sources.list.d/fk-neo-solr.list
RUN echo "deb [trusted=yes] http://10.47.4.220/repos/oracle_java8-debian-stretch-prod/1 /" > /etc/apt/sources.list.d/fk-neo-java.list
RUN echo "deb [trusted=yes] http://10.47.4.220/repos/fk-config-service-confd/67 /" > /etc/apt/sources.list.d/fk-neo-conf.list

RUN echo "deb [trusted=yes] http://10.47.4.220/repos/fk-neo-solr/209 /" > /etc/apt/sources.list.d/fk-neo-solr.list

RUN apt-get update

#export port num
EXPOSE 8983

#entry point commands
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
