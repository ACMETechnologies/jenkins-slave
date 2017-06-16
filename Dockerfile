FROM rancher/jenkins-slave 
MAINTAINER Landon Wainwright <landon@acmeticketing.com>

RUN apt-get update && apt-get -y upgrade && apt-get -y install bzip2

