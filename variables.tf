# Input Variables for for pet adotion project infrastructure
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "eu-west-2"
}
# Project Team
variable "project-team" {
  description = "Team Assigned the project (can be  used as a prefix)"
  type        = string
  default     = "EU2"
}
# Business Division (Pet Adoption Dvisison)
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "PET"
}

# VPC Name
variable "vpc_name" {
  description = "VPC for Pet Adoption Project"
  type        = string
  default     = "myvpc"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "Pub-SN_cidr1" {
  default     = "10.0.1.0/24"
  description = "cidr for public subnet 1"
}

variable "Pub-SN_cidr2" {
  default     = "10.0.2.0/24"
  description = "cidr for public subnet 2"
}

variable "Priv-SN_cidr1" {
  default     = "10.0.3.0/24"
  description = "cidr for private subnet 1"
}

variable "Priv-SN_cidr2" {
  default     = "10.0.4.0/24"
  description = "cidr for private subnet 1"
}

variable "all_access" {
  description = "this cidr allows all traffic from the web"
  type        = string
  default     = "0.0.0.0/0"
}


# VPC Availability Zone1
variable "vpc_availability_zone1" {
  description = "VPC AZs"
  type        = string
  default     = "eu-west-2a"
}

# VPC Availability Zone2
variable "vpc_availability_zone2" {
  description = "VPC AZs"
  type        = string
  default     = "eu-west-2b"
}

# VPC Public Subnets
variable "vpc_pub_sub1" {
  description = "VPC Public Subnet1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc_pub_sub2" {
  description = "VPC Public Subnet2"
  type        = string
  default     = "10.0.2.0/24"
}

# VPC Private Subnets
variable "vpc_priv_sub1" {
  description = "VPC Private Subnet1"
  type        = string
  default     = "10.0.3.0/24"
}

# VPC Private Subnets
variable "vpc_priv_sub2" {
  description = "VPC Private Subnet2"
  type        = string
  default     = "10.0.4.0/24"
}

# VPC Database Subnets
variable "vpc_database_subnets" {
  description = "VPC Database Subnets"
  type        = list(string)
  default     = ["10.0.151.0/24", "10.0.152.0/24"]
}

# VPC Create Database Subnet Group (True / False)
variable "vpc_create_database_subnet_group" {
  description = "VPC Create Database Subnet Group"
  type        = bool
  default     = true
}

# VPC Create Database Subnet Route Table (True or False)
variable "vpc_create_database_subnet_route_table" {
  description = "VPC Create Database Subnet Route Table"
  type        = bool
  default     = true
}


# VPC Enable NAT Gateway (True or False) 
variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
  default     = true
}

# VPC Single NAT Gateway (True or False)
variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type        = bool
  default     = true
}

#Various Ports
variable "http_port" {
  default     = 80
  description = "this port allows http access"
}
variable "proxy_port" {
  default     = 8080
  description = "this port allows proxy access"
}
variable "ssh_port" {
  default     = 22
  description = "this port allows ssh access"
}
variable "ssh_port" {
  default     = 9000
  description = "this port allows proxxy access"
}

# Database 

variable "database" {
    default = "capeu2db"
} 

variable "db_username" {
    default = "admin"
} 

variable "db_passwd" {
    default = "admin123"
}

#Database ports
variable "SSH_port" {
  default     = 22
  description = "this port allows http access"
}
variable "MYSQL_port" {
  default     = 3308
  description = "this port allows proxy access"
}

# LC Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.medium"
}
