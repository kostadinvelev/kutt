variable "ec2_instance_type" {
  description = "Type of EC2 instance to use"
  default     = "t2.micro"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "volume_size" {
  description = "Size of the EBS volume in GB"
  default     = 20
}
