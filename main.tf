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

#Backend SG - Database 

resource "aws_security_group" "DB_Backend_SG" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description      = "SSH_port"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.all_access]
  }  

  ingress {
    description      = "MYSQL_port"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.all_access]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all_access]
  }

  tags = {
    Name = "DB_Backend_SG"
  }
}

resource "aws_key_pair" "capeuteam2" {
  key_name   = "capeuteam2"
  public_key = file("~/keypair/capeuteam2.pub")
}

resource "aws_instance" "Sonarqube_Server" {
  ami                         = "ami-0f540e9f488cfa27d" #Ubuntu
  instance_type               = "t2.medium"
  key_name                    = "capeuteam2"
  vpc_security_group_ids      = ["${aws_security_group.PCJEU2_Sonarqube_SG.id}"]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.PCJEU2_Pub_SN1.id
  user_data                   = file("userdata.tpl")


  tags = {
    Name = "${local.name}-Sonarqube_Server"
  }
}

# Create Docker Host 
resource "aws_instance" "PCJEU2_Docker_Host" {
  ami                         = "ami-023cd3f0d10fb8a9c"
  associate_public_ip_address = true
  instance_type               = "t2.medium"
  key_name                    = "capeuteam2"
  subnet_id                   = aws_subnet.PCJEU2_Pub_SN1.id
  vpc_security_group_ids      = [aws_security_group.PCJEU2_Docker_SG.id]
  user_data                   = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo su
echo admin123 | passwd ec2-user --stdin
sudo bash -c ' echo "strictHostKeyChecking No" >> /etc/ssh/ssh_config
sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service sshd reload
sudo chmod -R 700 .ssh/
sudo chmod 600 .ssh/authorize_Keys
echo "license_key: licence key" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://downloads.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
EOF
  tags = {
    NAME = "${local.name}-Docker_Host"
  }
}

#create Jenkins server
resource "aws_instance" "jenkins_instance" {
  ami                         = "ami-023cd3f0d10fb8a9c"
  instance_type               = "t2.micro"
  key_name                    = "capeuteam2"
  subnet_id                   = aws_subnet.PCJEU2_Pub_SN2.id
  vpc_security_group_ids      = [aws_security_group.PCJEU2_Jenkins_SG.id]
  associate_public_ip_address = true
  user_data                   = file("userdata2.tpl")

  tags = {
    Name = "${local.name}-jenkins_instance"
  }
}

# Create EC2 Instance for Ansible Node
resource "aws_instance" "PCJEU2_Ansible_Node" {
  ami                    = "ami-023cd3f0d10fb8a9c"
  associate_public_ip_address = true
  instance_type          = "t2.medium"
  key_name               =  "capeuteam2"
  subnet_id              = aws_subnet.PCJEU2_Pub_SN1.id
  vpc_security_group_ids = [aws_security_group.PCJEU2_Ansible_SG.id]
  user_data              = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install python3 python3-pip -y
pip install ansible --user
sudo chown ec2-user:ec2-user /etc/ansible
sudo yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/sshpass-1.06-2.el7.x86_64.rpm
sudo yum install sshpass -y
echo "license_key: eu01xx28fc9087c229cd6428cc55448e87b8NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo su
echo admin123 | passwd ec2-user --stdin
echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service sshd reload
sudo chmod -R 700 .ssh/
sudo chown -R ec2-user:ec2-user .ssh/
sudo su - ec2-user -c "ssh-keygen -f ~/.ssh/capeuteam2 -t rsa -N''"
sudo bash -c ' echo "strictHostKeyChecking No" >> /etc/ssh/ssh_config
sudo su - ec2-user -c 'sshpass -p "Admin123@" ssh-copy-id -i /home/ec2-user/.ssh/capeuteam2.pub ec2-user@${aws_instance.PCJEU2_Docker_Host.public_ip} -p 22"
ssh-copy-id -i /home/ec2-user/.ssh/capeuteam2.pub ec2-user@localhost -p 22
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
cd /etc
sudo chown ec2-user:ec2-user hosts
cat <<EOT>> /etc/ansible/hosts
localhost ansible_connection=local
[docker_host]
${aws_instance.PCJEU2_Docker_Host.public_ip} ansible_ssh_private_key_file=/home/ec2-user/.ssh/capeuteam2
EOT
sudo mkdir /opt/docker
sudo chown -R ec2-user:ec2-user /opt/docker
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
                     -e NRIA_LICENSE_KEY=eu01xx4fc443b5ef136bb617380505f93e08NRAL \
                     newrelic/infrastructure:latest
EOT
EOF
tags = {
      NAME = "${local.name}-Ansible_Node"
  }
}

# Database 
resource "aws_db_instance" "PCJEU2_db" {
  allocated_storage = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  multi_az             = true 
  name              = var.database
  username             = var.db_username
  password             = var.db_passwd
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.DB_Backend_SG.id]
  db_subnet_group_name = aws_db_subnet_group.pcjeu2_db_subnet_group.id
}

#Database Subnet Group 
resource "aws_db_subnet_group" "pcjeu2_db_subnet_group" {
  name       = "pcjeu2_db_subnet_group"
  subnet_ids = [aws_subnet.PCJEU2_Priv_SN1.id, aws_subnet.PCJEU2_Priv_SN2.id]

  tags = {
    Name = "pcjeu2_db_subnet_group"
  }
}  
