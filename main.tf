
# Specify the minimum terraform version required
terraform {
  required_version = ">= 0.12"
}

# Specify the AWS region
provider "aws" {
  region = var.region
 }

# Generate a TLS private key
resource "tls_private_key" "createkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS key pair from the generated private key
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.createkey.public_key_openssh
}

# Save the generated private key to a file
resource "null_resource" "savekey"  {
  depends_on = [
    tls_private_key.createkey,
  ]
  
  provisioner "local-exec" {
    command = "echo '${tls_private_key.createkey.private_key_pem}' > jenkins_ec2_key.pem"
  }
}

# Create the Virtual Private Cloud (VPC)
resource "aws_vpc" "jenkins_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "jenkins_vpc"
  }
}

# Create the subnet within the VPC
resource "aws_subnet" "jenkins_subnet" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = "jenkins_subnet"
  }
}

# Create the internet gateway for the VPC
resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "jenkins-igw"
  }
}

# Create the route table for the VPC
resource "aws_route_table" "jenkins_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

  tags = {
    Name = "jenkins_rt"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "rt_association" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.jenkins_rt.id
}

# Create the security group for your EC2 instance
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = var.sg_description
  vpc_id      = aws_vpc.jenkins_vpc.id

  # Inbound Ruls
  ingress {
    description      = "Allow from Personal CIDR block"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Inbound Ruls
  ingress {
    description      = "Allow SSH from Personal CIDR block"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Outbound Ruls
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Jenkins SG"
  }
}

# Define the Amazon Machine Image (AMI) for your EC2 instance
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"] # Canonical
}

# Create the IAM role for your EC2 instance
resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create the IAM instance profile
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

# Create a policy for the IAM role
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  # Define the policy that allows all actions on all resources (for testing purposes only)
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
     }
  ]
}
EOF
}

# Create the EC2 instance
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.test_profile.name
  security_groups             = [aws_security_group.jenkins_sg.id]
  user_data                   = "${file("ec2Installations.sh")}"
  subnet_id                   = aws_subnet.jenkins_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "Jenkins"
  }
}
