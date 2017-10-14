#!/bin/bash

mkdir /var/jenkins_home/.ssh

aws s3 cp s3://infra-problem/keys/key.txt /var/jenkins_home/.ssh/id_rsa

chmod 400 /var/jenkins_home/.ssh/id_rsa

chown -R jenkins:jenkins /var/jenkins_home/.ssh
