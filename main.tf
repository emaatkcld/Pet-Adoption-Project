locals {
  owners       = var.business_divsion
  project-team = var.project-team
  name         = "${var.business_divsion}-${var.project-team}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    owners = local.owners
  }
}

# Create VPC
resource "aws_vpc" "PCJEU2_VPC" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${local.name}-vpc"
  }
}

#Create Public Subnet 1
resource "aws_subnet" "PCJEU2_Pub_SN1" {
  vpc_id            = aws_vpc.PCJEU2_VPC.id
  cidr_block        = var.vpc_pub_sub1
  availability_zone = var.vpc_availability_zone1
  tags = {
    Name = "${local.name}-PubSN1"
  }
}
#Create Public Subnet 2
resource "aws_subnet" "PCJEU2_Pub_SN2" {
  vpc_id            = aws_vpc.PCJEU2_VPC.id
  cidr_block        = var.vpc_pub_sub2
  availability_zone = var.vpc_availability_zone2
  tags = {
    Name = "${local.name}-PubSN2"
  }
}
#Create Priv Subnet 1
resource "aws_subnet" "PCJEU2_Priv_SN1" {
  vpc_id            = aws_vpc.PCJEU2_VPC.id
  cidr_block        = var.vpc_priv_sub1
  availability_zone = var.vpc_availability_zone1
  tags = {
    Name = "${local.name}-PrivSN1"
  }
}
#Create Priv Subnet 2
resource "aws_subnet" "PCJEU2_Priv_SN2" {
  vpc_id            = aws_vpc.PCJEU2_VPC.id
  cidr_block        = var.vpc_priv_sub2
  availability_zone = var.vpc_availability_zone2
  tags = {
    Name = "${local.name}-PrivSN2"
  }
}
#Create IGW
resource "aws_internet_gateway" "PCJEU2_IGW" {
  vpc_id = aws_vpc.PCJEU2_VPC.id
  tags = {
    Name = "${local.name}-IGW"
  }
}
#Create Elastic IP
resource "aws_eip" "PCJEU2_EIP" {
  vpc = true
  tags = {
    Name = "${local.name}-EIP"
  }
}

#Create NGW
resource "aws_nat_gateway" "PCJEU2_NGW" {
  subnet_id         = aws_subnet.PCJEU2_Pub_SN1.id
  connectivity_type = "private"

  tags = {
    Name = "${local.name}-NGW"
  }
}

#Create Public Route Table
resource "aws_route_table" "PCJEU2_Pub_RTB" {
  vpc_id = aws_vpc.PCJEU2_VPC.id

  route {
    cidr_block = var.all_access
    gateway_id = aws_internet_gateway.PCJEU2_IGW.id
  }

  tags = {
    Name = "${local.name}-PubRT"
  }
}

#Create Private Route Table
resource "aws_route_table" "PCJEU2_Priv_RTB" {
  vpc_id = aws_vpc.PCJEU2_VPC.id

  route {
    cidr_block = var.all_access
    gateway_id = aws_nat_gateway.PCJEU2_NGW.id
  }

  tags = {
    Name = "${local.name}-PrivRT"
  }
}

#Create Pub SN1 Association
resource "aws_route_table_association" "PCJEU2_Pub_RTB_AS1" {
  subnet_id      = aws_subnet.PCJEU2_Pub_SN1.id
  route_table_id = aws_route_table.PCJEU2_Pub_RTB.id
}

#Create Pub SN2 Association
resource "aws_route_table_association" "PCJEU2_Pubd_RTB_AS2" {
  subnet_id      = aws_subnet.PCJEU2_Pub_SN2.id
  route_table_id = aws_route_table.PCJEU2_Pub_RTB.id
}

#Create Priv SN1 Association
resource "aws_route_table_association" "PCJEU2_Priv_RTB_AS1" {
  subnet_id      = aws_subnet.PCJEU2_Priv_SN1.id
  route_table_id = aws_route_table.PCJEU2_Priv_RTB.id
}

#Create Priv SN2 Association
resource "aws_route_table_association" "PCJEU2_Priv_RTB_AS2" {
  subnet_id      = aws_subnet.PCJEU2_Priv_SN2.id
  route_table_id = aws_route_table.PCJEU2_Priv_RTB.id
}


#Create Security Group for Ansible
resource "aws_security_group" "PCJEU2_Ansible_SG" {
  name        = "${local.name}-Ansible"
  description = "Allow Inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_access]
  }

  tags = {
    Name = "${local.name}-Ansible_SG"
  }
}

#Create Security Group for Docker
resource "aws_security_group" "PCJEU2_Docker_SG" {
  name        = "${local.name}-Docker"
  description = "Allow Inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.proxy_port
    to_port     = var.proxy_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.proxxy_port
    to_port     = var.proxxy_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_access]
  }

  tags = {
    Name = "${local.name}-Docker_SG"
  }
}

#Create Security Group for Jenkins
resource "aws_security_group" "PCJEU2_Jenkins_SG" {
  name        = "${local.name}-Jenkins"
  description = "Allow Inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.proxy_port
    to_port     = var.proxy_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_access]
  }

  tags = {
    Name = "${local.name}-Jenkins_SG"
  }
}

#Create Security Group for Sonarqube
resource "aws_security_group" "PCJEU2_Sonarqube_SG" {
  name        = "${local.name}-Sonaqube"
  description = "Allow Inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.proxy_port
    to_port     = var.proxy_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.proxxy_port
    to_port     = var.proxxy_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_access]
  }

  tags = {
    Name = "${local.name}-Sonarqube_SG"
  }
}

#Create Security Group for LC ALB
resource "aws_security_group" "PCJEU2_LC_SG" {
  name        = "${local.name}-LC"
  description = "Allow Inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.proxy_port
    to_port     = var.proxy_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  ingress {
    description = "Allow inbound traffic"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_access]
  }

  tags = {
    Name = "${local.name}-LC_SG"
  }
}

#Backend SG - Database 
resource "aws_security_group" "DB_Backend_SG" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description = "MYSQL_port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.all_access]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_access]
  }

  tags = {
    Name = "${local.name}-DB_Backend_SG"
  }
}

resource "aws_instance" "Sonarqube_Server" {
  ami                         = var.ami
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = var.instance_keypair
  vpc_security_group_ids      = ["${aws_security_group.PCJEU2_Sonarqube_SG.id}"]
  subnet_id                   = aws_subnet.PCJEU2_Pub_SN1.id
  #user_data                   = file("userdata.tpl")
  user_data = <<-EOF
  #!/bin/bash 
  sudo apt update -y
  sudo apt install docker.io -y
  sudo docker run -itd --name sonar-container -p 9000:9000 sonarqube
  EOF

  tags = {
    Name = "${local.name}-Sonarqube_Server"
  }
}

# Create Docker Host 
resource "aws_instance" "PCJEU2_Docker_Host" {
  ami                         = var.ami
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = var.instance_keypair
  subnet_id                   = aws_subnet.PCJEU2_Pub_SN1.id
  vpc_security_group_ids      = [aws_security_group.PCJEU2_Docker_SG.id]
  user_data                   = <<-EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install docker.io -y
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker ubuntu
  sudo -i
  echo admin123 | passwd ubuntu --stdin
  echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  sudo bash -c ' echo "strictHostKeyChecking No" >> /etc/ssh/ssh_config'
  sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sudo service sshd reload
  sudo chmod -R 700 .ssh/
  sudo chmod 600 .ssh/authorized_keys
  # echo "license_key: 19934c8af59dee4336ee880bff8a7f28c60cNRAL" | sudo tee -a /etc/newrelic-infra.yml
  # sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://downloads.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
  # sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
  # sudo yum install newrelic-infra -y
  EOF
  tags = {
    Name = "${local.name}-Docker_Host"
  }
}

#create Jenkins server
resource "aws_instance" "jenkins_instance" {
  ami                         = var.ami
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = var.instance_keypair
  subnet_id                   = aws_subnet.PCJEU2_Pub_SN2.id
  vpc_security_group_ids      = [aws_security_group.PCJEU2_Jenkins_SG.id]
  user_data = <<-EOF
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
  sudo su - ubuntu -c "ssh-keygen -f ~/.ssh/jenkins-key -t rsa -b 4096 -m PEM -N ''" 
  cat ~/.ssh/jenkins-key.pub | ssh ubuntu@${aws_instance.PCJEU2_Ansible_Node.public_ip} "cat >> ~/.ssh/authorized_keys"
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
  EOF

  tags = {
    Name = "${local.name}-jenkins_instance"
  }
}

# Create EC2 Instance for Ansible Node
resource "aws_instance" "PCJEU2_Ansible_Node" {
  ami                         = var.ami
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = var.instance_keypair
  subnet_id                   = aws_subnet.PCJEU2_Pub_SN1.id
  vpc_security_group_ids      = [aws_security_group.PCJEU2_Ansible_SG.id]
  user_data                   = <<-EOF
  #!/bin/bash
  sudo apt-get update -y 
  sudo apt-add-repository ppa:ansible/ansible 
  sudo apt-get install ansible -y
  sudo apt-get install sshpass -y
  sudo -i
  #echo admin123 | passwd ubuntu --stdin
  #echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  #sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  #sudo service sshd reload

  #################################################################################################
  #either create a key and copy the .pub of the key into the docker server or
  #copy the private key with which you ssh into ansible into the other servers you would want to connect with
  #################################################################################################

  echo "${file(var.key)}" >> ~/.ssh/id_rsa
  # sudo su - ubuntu -c "ssh-keygen -f ~/.ssh/ansible-key -t rsa -N ''"
  # sudo bash -c ' echo "strictHostKeyChecking=No" >> /etc/ssh/ssh_config'
  # sudo su - ubuntu -c 'sshpass -p "admin123" ssh-copy-id -i /home/ubuntu/.ssh/ansible-key.pub ubuntu@${aws_instance.PCJEU2_Docker_Host.public_ip} -p 22'
  # sudo ssh-copy-id -i /home/ubuntu/.ssh/ansible-key.pub ubuntu@localhost -p 22
  sudo apt-get install docker.io -y
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker ubuntu
  cd /etc
  sudo chown ubuntu:ubuntu hosts
  cat <<EOT>> /etc/ansible/hosts
  localhost ansible_connection=local
  [docker_host]
  ${aws_instance.PCJEU2_Docker_Host.public_ip} ansible_ssh_private_key_file=/home/ubuntu/.ssh/ansible-key
  EOT
  sudo mkdir /opt/docker
  sudo chown -R ubuntu:ubuntu /opt/docker
  sudo chmod -R 700 /opt/docker
  touch /opt/docker/Dockerfile
  cat <<EOT>> /opt/docker/Dockerfile
  # pull tomcat image from docker hub
  FROM tomcat
  FROM openjdk:8-jre-slim
  #copy war file on the container
  COPY spring-petclinic-2.4.2.war app/
  WORKDIR app/
  RUN pwd
  RUN ls -al
  ENTRYPOINT [ "java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"]
  EOT
  touch /opt/docker/docker-image.yml
  cat <<EOT>> /opt/docker/docker-image.yml
  ---
   - hosts: localhost
    #root access to user
     become: true

     tasks:
     - name: login to dockerhub
       command: docker login -u cloudhight -p CloudHight_Admin123@

     - name: Create docker image from Pet Adoption war file
       command: docker build -t pet-adoption-image .
       args:
         chdir: /opt/docker

     - name: Add tag to image
       command: docker tag pet-adoption-image cloudhight/pet-adoption-image

     - name: Push image to docker hub
       command: docker push cloudhight/pet-adoption-image

     - name: Remove docker image from Ansible node
       command: docker rmi pet-adoption-image cloudhight/pet-adoption-image
       ignore_errors: yes
  EOT
  touch /opt/docker/docker-container.yml
  cat <<EOT>> /opt/docker/docker-container.yml
  ---
   - hosts: docker_host
     become: true

     tasks:
     - name: login to dockerhub
       command: docker login -u cloudhight -p CloudHight_Admin123@

     - name: Stop any container running
       command: docker stop pet-adoption-container
       ignore_errors: yes

     - name: Remove stopped container
       command: docker rm pet-adoption-container
       ignore_errors: yes

     - name: Remove docker image
       command: docker rmi cloudhight/pet-adoption-image
       ignore_errors: yes

     - name: Pull docker image from dockerhub
       command: docker pull cloudhight/pet-adoption-image
       ignore_errors: yes

     - name: Create container from pet adoption image
       command: docker run -it -d --name pet-adoption-container -p 8080:8085 cloudhight/pet-adoption-image
       ignore_errors: yes
  EOT
  cat << EOT > /opt/docker/newrelic.yml
  ---
   - hosts: docker
     become: true

     tasks:
     - name: install newrelic agent
       command: docker run \
                       -d \
                       --name newrelic-infra \
                       --network=host \
                       --cap-add=SYS_PTRACE \
                       --privileged \
                       --pid=host \
                       -v "/:/host:ro" \
                       -v "/var/run/docker.sock:/var/run/docker.sock" \
                       -e NRIA_LICENSE_KEY=19934c8af59dee4336ee880bff8a7f28c60cNRAL \
                       newrelic/infrastructure:latest
                       
  EOT
  EOF

  tags = {
    Name = "${local.name}-Ansible_Node"
  }
}


    #user_data                   = <<-EOF
  # #!/bin/bash
  # sudo yum update -y
  # sudo yum install python3 python3-pip -y
  # pip install ansible --user
  # sudo dnf -y install https://dl.fedoraproject.org/epel/epel-release-latest-8.noarch.rpm
  # sudo yum install ansible - y
  # sudo chown ec2-user:ec2-user /etc/ansible
  # sudo yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/sshpass-1.06-2.el7.x86_64.rpm
  # sudo yum install sshpass -y
  # echo "license_key: eu01xxbca018499adedd74cacda9d3d13e7dNRAL" | sudo tee -a /etc/newrelic-infra.yml
  # sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
  # sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
  # sudo yum install newrelic-infra -y
  # sudo -i
  # echo admin123 | passwd ec2-user --stdin
  # echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  # sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  # sudo service sshd reload
  # sudo chmod -R 700 .ssh/
  # sudo chown -R ec2-user:ec2-user .ssh/
  # sudo su - ec2-user -c "ssh-keygen -f ~/.ssh/capeuteam2 -t rsa -N ''"
  # sudo bash -c ' echo "strictHostKeyChecking=No" >> /etc/ssh/ssh_config'
  # sudo su - ec2-user -c 'sshpass -p "admin123" ssh-copy-id -i /home/ec2-user/.ssh/capeuteam2.pub ec2-user@${aws_instance.PCJEU2_Docker_Host.public_ip} -p 22'
  # ssh-copy-id -i /home/ec2-user/.ssh/capeuteam2.pub ec2-user@localhost -p 22
  # sudo yum install -y yum-utils
  # sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  # sudo yum install docker-ce -y
  # sudo systemctl start docker
  # sudo systemctl enable docker
  # sudo usermod -aG docker ec2-user
  # cd /etc
  # sudo chown ec2-user:ec2-user hosts
  # cat <<EOT>> /etc/ansible/hosts
  # localhost ansible_connection=local
  # [docker_host]
  # ${aws_instance.PCJEU2_Docker_Host.public_ip} ansible_ssh_private_key_file=/home/ec2-user/.ssh/capeuteam2
  # EOT
  # sudo mkdir /opt/docker
  # sudo chown -R ec2-user:ec2-user /opt/docker
  # sudo chmod -R 700 /opt/docker
  # touch /opt/docker/Dockerfile
  # cat <<EOT>> /opt/docker/Dockerfile
  # # pull tomcat image from docker hub
  # FROM tomcat
  # FROM openjdk:8-jre-slim
  # #copy war file on the container
  # COPY spring-petclinic-2.4.2.war app/
  # WORKDIR app/
  # RUN pwd
  # RUN ls -al
  # ENTRYPOINT [ "java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"]
  # EOT
  # touch /opt/docker/docker-image.yml
  # cat <<EOT>> /opt/docker/docker-image.yml
  # ---
  #  - hosts: localhost
  #   #root access to user
  #    become: true

  #    tasks:
  #    - name: login to dockerhub
  #      command: docker login -u cloudhight -p CloudHight_Admin123@

  #    - name: Create docker image from Pet Adoption war file
  #      command: docker build -t pet-adoption-image .
  #      args:
  #        chdir: /opt/docker

  #    - name: Add tag to image
  #      command: docker tag pet-adoption-image cloudhight/pet-adoption-image

  #    - name: Push image to docker hub
  #      command: docker push cloudhight/pet-adoption-image

  #    - name: Remove docker image from Ansible node
  #      command: docker rmi pet-adoption-image cloudhight/pet-adoption-image
  #      ignore_errors: yes
  # EOT
  # touch /opt/docker/docker-container.yml
  # cat <<EOT>> /opt/docker/docker-container.yml
  # ---
  #  - hosts: docker_host
  #    become: true

  #    tasks:
  #    - name: login to dockerhub
  #      command: docker login -u cloudhight -p CloudHight_Admin123@

  #    - name: Stop any container running
  #      command: docker stop pet-adoption-container
  #      ignore_errors: yes

  #    - name: Remove stopped container
  #      command: docker rm pet-adoption-container
  #      ignore_errors: yes

  #    - name: Remove docker image
  #      command: docker rmi cloudhight/pet-adoption-image
  #      ignore_errors: yes

  #    - name: Pull docker image from dockerhub
  #      command: docker pull cloudhight/pet-adoption-image
  #      ignore_errors: yes

  #    - name: Create container from pet adoption image
  #      command: docker run -it -d --name pet-adoption-container -p 8080:8085 cloudhight/pet-adoption-image
  #      ignore_errors: yes
  # EOT
  # cat << EOT > /opt/docker/newrelic.yml
  # ---
  #  - hosts: docker
  #    become: true

  #    tasks:
  #    - name: install newrelic agent
  #      command: docker run \
  #                      -d \
  #                      --name newrelic-infra \
  #                      --network=host \
  #                      --cap-add=SYS_PTRACE \
  #                      --privileged \
  #                      --pid=host \
  #                      -v "/:/host:ro" \
  #                      -v "/var/run/docker.sock:/var/run/docker.sock" \
  #                      -e NRIA_LICENSE_KEY=19934c8af59dee4336ee880bff8a7f28c60cNRAL \
  #                      newrelic/infrastructure:latest
  # EOT
  # EOF
  

##Every line of code up till this 560 support application deployment
#All codes from 567 should be commented out before the first apply.
#After application deployment phase, uncomment after deployment to proceed to HA
# Create AMI from Docker Host
resource "aws_ami_from_instance" "PCJEU2-Docker-ami" {
  name                    = "PCJEU2-Docker-ami"
  source_instance_id      = aws_instance.PCJEU2_Docker_Host.id
  snapshot_without_reboot = true
}

#Create Target Group for Load Balancer
resource "aws_lb_target_group" "PCJEU2-TG" {
  name     = "${local.name}-lb-alb-TG"
  port     = "8080"
  protocol = "HTTP"
  vpc_id   = aws_vpc.PCJEU2_VPC.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    interval            = 60
    timeout             = 5
  }
}

#Creat Target Group Attachment
resource "aws_lb_target_group_attachment" "PCJEU2-tg-attch" {
  target_group_arn = aws_lb_target_group.PCJEU2-TG.arn
  target_id        = aws_instance.PCJEU2_Docker_Host.id
  port             = 8080
}


# Creating the Application Load Balancer
resource "aws_lb" "PCJEU2-lb" {
  name                       = "PCJEU2-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.PCJEU2_Docker_SG.id]
  subnets                    = [aws_subnet.PCJEU2_Pub_SN1.id, aws_subnet.PCJEU2_Pub_SN2.id]
  enable_deletion_protection = false

  tags = {
    name = "PCJEU2-lb"
  }

}

#Lunch Configuration Template
resource "aws_launch_configuration" "PCJEU2_LC" {
  name                        = "${local.name}-LC"
  image_id                    = aws_ami_from_instance.PCJEU2-Docker-ami.id
  instance_type               = var.instance_type
  key_name                    = var.instance_keypair
  security_groups             = [aws_security_group.PCJEU2_Docker_SG.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
  #!/bin/bash
  sudo docker restart pet-adoption-container
  EOF

  depends_on = [
    aws_security_group.PCJEU2_Docker_SG
  ]
}

# Creating Route53 Hosted Zone
resource "aws_route53_zone" "Hosted_zone" {
  name = "awaiye.com"

  tags = {
    Environment = "dev"
  }
}

# A record pointing to a load balancer
resource "aws_route53_record" "PCJEU2_record" {
  zone_id = aws_route53_zone.Hosted_zone.zone_id
  name    = "awaiye.com"
  type    = "A"
  alias {
    name                   = aws_lb.PCJEU2-lb.dns_name
    zone_id                = aws_lb.PCJEU2-lb.zone_id
    evaluate_target_health = true
  }
}

#Create AutoScaling Group
resource "aws_autoscaling_group" "PCJEU2-ASG" {
  name                      = "${local.name}-ASG"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  launch_configuration      = aws_launch_configuration.PCJEU2_LC.name
  vpc_zone_identifier       = [aws_subnet.PCJEU2_Pub_SN1.id, aws_subnet.PCJEU2_Pub_SN2.id]
  target_group_arns         = [aws_lb_target_group.PCJEU2-TG.arn]

}

#Create ASG Policy
resource "aws_autoscaling_policy" "PCJEU2-ASG-Policy" {
  name = "${local.name}-ASG-Pol"
  #scaling_adjustment     = 4
  policy_type     = "TargetTrackingScaling"
  adjustment_type = "ChangeInCapacity"
  #cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.PCJEU2-ASG.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 30.0
  }
}

# Create Load Balancer Listener for Docker
resource "aws_lb_listener" "PCJEU2_lb_listener" {
  load_balancer_arn = aws_lb.PCJEU2-lb.arn
  #load_balancer_arn = aws_lb.PCJEU2-lb_listener.arn
  port     = "80"
  protocol = "HTTP"
  #load_balancer_arn = aws_lb.PCJEU2_lb_listener.arn
  #port              = "80"
  #protocol          = "HTTPS"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PCJEU2-TG.arn
  }
}


