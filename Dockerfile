FROM ubuntu:xenial

MAINTAINER Gabor Debreczeni-Kis <gabor@acmeticketing.com>

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install apt-utils dialog
RUN apt-get update && apt-get -y upgrade && apt-get -y install software-properties-common openjdk-8-jdk bzip2 libfontconfig

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH


# apparmor is required to run docker server within docker container
RUN apt-get update -qq && apt-get install -qqy wget curl git iptables ca-certificates apparmor

ENV JENKINS_SWARM_VERSION 3.6
ENV HOME /home/jenkins-slave


RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave
RUN curl --create-dirs -sSLo $HOME/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar
ADD cmd.sh /cmd.sh

# set our wrapper
ENTRYPOINT ["/usr/local/bin/docker-wrapper"]

# setup our local files first
ADD docker-wrapper.sh /usr/local/bin/docker-wrapper
RUN chmod +x /usr/local/bin/docker-wrapper

# now we install docker in docker - thanks to https://github.com/jpetazzo/dind
# We install newest docker into our docker in docker container
RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz \
  && tar --strip-components=1 -xvzf docker-latest.tgz -C /usr/local/bin \
  && chmod +x /usr/local/bin/docker \
# install Rancher CLI
  && curl -fsSLO https://github.com/rancher/cli/releases/download/v0.6.7/rancher-linux-amd64-v0.6.7.tar.gz \
  && tar --strip-components=2 -xzvf rancher-linux-amd64-v0.6.7.tar.gz -C /usr/local/bin \
  && chmod +x /usr/local/bin/rancher

VOLUME /var/lib/docker

#ENV JENKINS_USERNAME jenkins
#ENV JENKINS_PASSWORD jenkins
#ENV JENKINS_MASTER http://jenkins:8080

CMD /bin/bash /cmd.sh
