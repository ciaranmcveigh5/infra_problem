FROM jenkins/jenkins:latest

MAINTAINER Ciaran McVeigh

# Environment Variables

ENV JAVA_OPTS="-Dhudson.Main.development=true -Djenkins.install.runSetupWizard=false"

ENV ANSIBLE_HOST_KEY_CHECKING=False


# Copy Init Scripts

COPY scripts/init/ usr/share/jenkins/ref/init.groovy.d

# Copy Plugins

COPY plugins/plugins.txt usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < usr/share/jenkins/ref/plugins.txt

# Copy Jobs

COPY jobs/ $JENKINS_HOME/jobs/

# Copy Bitbucket Credentials

COPY misc/credentials.xml $JENKINS_HOME/credentials.xml

# ROOT COMMANDS

USER root

# Change Ownership

RUN chown -R jenkins:jenkins $JENKINS_HOME

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/0.10.7/terraform_0.10.7_linux_amd64.zip -P /usr/bin
RUN unzip /usr/bin/terraform_0.10.7_linux_amd64.zip -d /usr/bin
RUN rm /usr/bin/terraform_0.10.7_linux_amd64.zip
RUN curl https://raw.githubusercontent.com/apex/apex/master/install.sh | sh

# Install AWS CLI

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y \
    ansible \
    less \
    man \
    ssh \
    python \
    python-pip \
    python-virtualenv \
    git \
    sudo \
    vim

RUN pip install awscli

RUN printf "[app]\n10.1.5.197" > /etc/ansible/hosts

COPY scripts/key/key.sh /tmp/key.sh
RUN chmod +x /tmp/key.sh
