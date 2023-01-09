#!/bin/bash
  sudo apt update -y
  
  echo "**Firstly Modify OS Level values**"
  sudo vm.max_map_count=262144
  sudo fs.file-max=65536
  ulimit -n 65536
  ulimit -u 4096
  sudo apt-get update -y
  echo "****Install Java JDK****"
  sudo apt-get install wget unzip -y
  sudo apt-get install openjdk-11-jdk -y
  sudo apt-get install openjdk-11-jre -y
  #to set deafult JDK or awitch to openJDK entre below command
  sudo update-alternatives --config java
  java -version

  #Step 2 - install and setup PostgreSQL 10 db for sonarqube. Add and download postgreSQL repo
  echo "****Install PostgreSQL****"
  echo "****The version of postgres currenlty is 14.5 which is not supported so we have to download v12****"
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo apt-get update -y
  sudo apt-get -y install postgresql-12 postgresql-contrib-12
  echo "**Enable and start, so it starts when system boots up**"
  sudo systemctl enable postgresql
  sudo systemctl start postgresql
  sudo systemctl status postgresql
  #Change default password of postgres user
  sudo chpasswd <<<"postgres:admin123"
  #Create user sonar without switching technically
  sudo su -c 'createuser sonar' postgres
  #Create SonarQube Database and change sonar password
  sudo su -c "psql -c \"ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123'\"" postgres
  sudo su -c "psql -c \"CREATE DATABASE sonarqube OWNER sonar\"" postgres
  sudo su -c "psql -c \"grant all privileges on DATABASE sonarqube to sonar\"" postgres
  #Restart postgresql for changes to take effect
  sudo systemctl restart postgresql
  #Install SonarQube www.sonarqube.org/downloads
  sudo mkdir /sonarqube/
  cd /sonarqube/
  wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.6.0.39681.zip
  sudo apt-get install unzip -y
  sudo unzip sonarqube-8.6.0.39681.zip -d /opt/
  sudo mv /opt/sonarqube-8.6.0.39681/ /opt/sonarqube
  #Add group user sonarqube
  sudo groupadd sonar
  #Then, create a user and add the user into the group with directory permission to the /opt/ directory
  sudo useradd -c "SonarQube - user" -d /opt/sonarqube/ -g sonar sonar
  #Change ownership of the directory to sonar
  sudo chown sonar:sonar /opt/sonarqube/ -R
  #open sonarqube configuration file any file editor you are confortable with
  sudo bash -c 'echo "
  sonar.jdbc.username=sonar
  sonar.jdbc.password=admin123
  sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
  sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError" >> /opt/sonarqube/conf/sonar.properties'
  #Configure such that SonarQube starts on boot up
  sudo touch /etc/systemd/system/sonarqube.service
  #Configuring so that we can run commands to start, stop and reload sonarqube service
  sudo bash -c 'echo "
  [Unit]
  Description=SonarQube service
  After=syslog.target network.target

  [Service]
  Type=forking

  ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
  ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
  ExecReload=/opt/sonarqube/bin/linux-x86-64/sonar.sh restart

  User=sonar
  Group=sonar
  Restart=always

  LimitNOFILE=65536
  LimitNPROC=4096
  [Install]
  WantedBy=multi-user.target" >> /etc/systemd/system/sonarqube.service'
  #Enable and Start the Service
  sudo systemctl daemon-reload
  sudo systemctl enable sonarqube.service
  sudo systemctl start sonarqube.service
#Install net-tools incase we want to debug later
  sudo apt install net-tools -y
  #Install nginx
  sudo apt-get install nginx -y
  #Configure nginx so we can access server from outside
  sudo touch /etc/nginx/sites-enabled/sonarqube.conf
  sudo bash -c 'echo "
  server {
    listen 80;
    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;
    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
  }" >> /etc/nginx/sites-enabled/sonarqube.conf'
  #Remove the default configuration file
  sudo rm /etc/nginx/sites-enabled/default
  #Enable and restart nginix service
  sudo systemctl enable nginx.service
  sudo systemctl stop nginx.service
  sudo systemctl start nginx.service

  #Install New relic
  echo "license_key: 19934c8af59dee4336ee880bff8a7f28c60cNRAL" | sudo tee -a /etc/newrelic-infra.yml
  sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://downloads.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
  sudo apr-get -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
  sudo apt-get install newrelic-infra -y
  echo "*****Change Hostname(IP) to something readable*****"
  sudo hostnamectl set-hostname Sonarqube
  sudo reboot
EOF 


.............................................................................
# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt-get -y install postgresql