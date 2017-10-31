FROM debian:latest
MAINTAINER Martin Ponbauer <martin.ponbauer@zuehlke.com>

#This makes debconf use a frontend that expects no interactive input at all
ARG DEBIAN_FRONTEND=noninteractive

#Copy everything within ./config into the root directory of the container
COPY config/* /

#Download and Install required packages to proceed
RUN apt-get update && \
    apt-get -y install apt-utils && \
    apt-get -y install default-jdk && \
    apt-get -y install curl wget && \
    apt-get -y install vim nano && \
    apt-get -y install openssl && \
    apt-get -y install bzip2 xz-utils unzip locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8

#Download and Install of Bamboo 6.2.1
RUN mkdir -p /opt/atlassian/bamboo /var/atlassian/application/bamboo && \
    wget https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-6.2.1.tar.gz -q && \
    tar -xvf atlassian-bamboo-6.2.1.tar.gz && \
    rm -f atlassian-bamboo-6.2.1.tar.gz && \
    mv atlassian-bamboo-6.2.1/* /opt/atlassian/bamboo

#Download and Install Docker Community Edition
RUN apt-get update && \
    apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce

#Download and Install Nodes.js Angular CLI and webdriver-manager
RUN curl https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo "deb https://deb.nodesource.com/node_8.x $(lsb_release -s -c) main" | tee /etc/apt/sources.list.d/nodesource.list && \
    echo "deb-src https://deb.nodesource.com/node_8.x $(lsb_release -s -c) main" | tee -a /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get -y install python2.7 && \
    apt-get -y install nodejs && \
    npm install -g --unsafe-perm webdriver-manager

#Download and Install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && apt-get install -y google-chrome-stable

#Download and Install Sonarqube Scanner
RUN wget -q https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip &&\
    unzip sonar-scanner-cli-3.0.3.778-linux.zip -d /opt/sonarqube/ &&\
    rm -f sonar-scanner-cli-3.0.3.778-linux.zip &&\
    echo "PATH=$PATH:/opt/sonarqube/sonar-scanner-3.0.3.778-linux/bin" >> ~/.bashrc &&\
    mv sonar-scanner.properties /opt/sonarqube/sonar-scanner-3.0.3.778-linux/conf/sonar-scanner.properties

#Change directory to the Bamboo installation directory
WORKDIR /opt/atlassian/bamboo

#Copy MySQL JDBC Connector into /opt/atlassian/bamboo/lib
COPY db-connector/mysql-connector-java-5.1.42-bin.jar lib

#Setting Bamboo home directory permamently
RUN echo "bamboo.home=/var/atlassian/application/bamboo" >> atlassian-bamboo/WEB-INF/classes/bamboo-init.properties

#Start Bamboo in the foreground
CMD bin/start-bamboo.sh -fg & bash
