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

#Create Security Group for Sonaqube
resource "aws_security_group" "PCJEU2_Sonaqube_SG" {
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
    Name = "${local.name}-Sonaqube_SG"
  }
}



