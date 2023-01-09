#!/bin/bash
sudo apt-get update -y
sudo apt-get install wget -y
sudo apt-get install maven -y
sudo apt-get install git -y
sudo apt-get install default-jre -y
sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get upgrade -y
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins
sudo apt-config-manager --add-repo https://download.docker.com/linux/ubutu/docker-ce.repo
sudo apt-get install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
sudo hostnamectl set-hostname Jenkins
echo "license_key: 19934c8af59dee4336ee880bff8a7f28c60cNRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/apt.repos.d/newrelic-infra.repo https://downloads.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y