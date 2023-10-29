variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "jenkins_ec2_key" 
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.xlarge"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "sg_description" {
  description = "Description for security group"
  type        = string
  default     = "Allow inbound SSH traffic"
}
