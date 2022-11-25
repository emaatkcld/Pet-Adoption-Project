# Create VPC
resource "aws_vpc" "PCJEU2_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "PCJEU2_VPC"
  }
}

#Create Public Subnet 1
resource "aws_subnet" "PCJEU2_Pub_SN1" {
  vpc_id            = aws_vpc.PCJEU2_VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "PCJEU2_Pub_SN1"
  }
}

#Create Public Subnet 2
resource "aws_subnet" "PCJEU2_Pub_SN2" {
  vpc_id            = aws_vpc.PCJEU2_VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "PCJEU2_Pub_SN2"
  }
}

#Create Priv Subnet 1
resource "aws_subnet" "PCJEU2_Priv_SN1" {
  vpc_id            = aws_vpc.PCJEU2_VPC.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "PCJEU2_Priv_SN1"
  }
}

#Create Priv Subnet 2
resource "aws_subnet" "PCJEU2_Priv_SN2" {
  vpc_id            = aws_vpc.PCJEU2_VPC.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "PCJEU2_Priv_SN2"
  }
}

#Create IGW
resource "aws_internet_gateway" "PCJEU2_IGW" {
  vpc_id = aws_vpc.PCJEU2_VPC.id

  tags = {
    Name = "PCJEU2_IGW"
  }
}
#Create Elastic IP
resource "aws_eip" "PCJEU2_NGW" {
  vpc = true

}
#Create SG for Jenkins
resource "aws_security_group" "PCJEU2-JENKINS-SG" {
  name        = "PCJEU2-JENKINS-SG"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "PROXY-PORT"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PCJEU2-JENKINS-SG"
  }
}
#Create SG for ANSIBLE
resource "aws_security_group" "PCJEU2-ANSIBLE-SG" {
  name        = "PCJEU2-ANSIBLE-SG"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "PCJEU2-ANSIBLE-SG"
  }
}
#Create SG for Docker
resource "aws_security_group" "PCJEU2-DOCKER-SG" {
  name        = "PCJEU2-DOCKER-SG"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "PROXY-PORT"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PCJEU2-DOCKER-SG"
  }
}
#Create SG for Docker
resource "aws_security_group" "PCJEU2-SONARQUBE-SG" {
  name        = "PCJEU2-SONARQUBE-SG"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.PCJEU2_VPC.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "PROXY-PORT"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PCJEU2-SONARQUBE-SG"
  }
}

resource "aws_instance" "Sonarqube_Server" {
  ami                         = "ami-08c40ec9ead489470" #Ubuntu
  instance_type               = "t2.medium"
  key_name                    = "capeuteam2"
  vpc_security_group_ids      = ["${aws_security_group.PCJEU2-SONARQUBE-SG.id}"]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.PCJEU2_Pub_SN1.id
  user_data                   = file("userdata.tpl")


  tags = {
    Name = "Sonarqube_Server"
  }
}
