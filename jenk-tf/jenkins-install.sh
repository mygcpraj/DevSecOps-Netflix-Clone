#!/bin/bash 

## Setup Docker 

sudo apt-get update -y 

sudo apt-get install docker.io -y

sudo usermod -aG docker ubuntu  

newgrp docker

sudo chmod 777 /var/run/docker.sock

## Install Trivy for image scanning 

sudo apt-get install -y wget apt-transport-https gnupg lsb-release

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list

sudo apt-get update -y

sudo apt-get install -y trivy        


### Install Openjdk 

sudo apt update -y

sudo apt install -y fontconfig openjdk-17-jre

java -version

# Install jenkins

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y jenkins

sudo systemctl start jenkins

sudo systemctl enable jenkins

