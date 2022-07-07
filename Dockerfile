#Download base image from docker hub
FROM ubuntu:18.04

## Set working directory to for deployment ##
##WORKDIR /opt/

RUN mkdir -p /data

## Install system update and required packages ##
## Keep default ##

RUN apt-get update && \
  apt-get install -y --no-install-recommends locales && \
  locale-gen en_US.UTF-8 && \
  apt-get dist-upgrade -y && \  
  apt-get install -y tzdata && \ 
  apt-get install -y net-tools && \  
  apt-get install -y inetutils-ping && \
  apt-get install -y lsof && \
  apt-get install -y build-essential && \
  apt-get install -y wget && \
  apt-get install -y dpkg && \
  apt-get -y install git && \
  apt-get install -y python3-pip && \
  apt-get install -y rsync && \   
  apt-get clean all
  
RUN wget https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.deb && \
    dpkg -i vagrant_2.2.5_x86_64.deb 
	
RUN pip3 install awscli --upgrade --user && \
ln -s /root/.local/bin/aws /usr/local/bin/aws

RUN vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box  && \
	  vagrant plugin install vagrant-aws && \   
    vagrant plugin install vagrant-winrm-syncedfolders
    
RUN apt-get update && \ 
    apt-get install -y software-properties-common && \
    add-apt-repository multiverse
     
    
# coping swiftalm budle into the container
#COPY devops .
COPY .aws  /root/.aws
COPY AmazonCloudKeyPair.pem  /data/aws/

# Setting executable permission
RUN find -type f -iname "*.sh" -exec chmod +x {} \;

# Configure Services and Port
EXPOSE 80 8080

#RUN sh entrypoint.sh --silent
CMD ["/bin/bash"]