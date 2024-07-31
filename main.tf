resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "KuttVPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "KuttPublicSubnet"
  }
}

resource "aws_security_group" "allow_ssh_http" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "AllowSSHHTTP"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "KuttIGW"
  }

  depends_on = [
    aws_instance.kutt_instance,
    aws_volume_attachment.attach_ebs,
    aws_eip.kutt_eip
  ]  # Ensure EC2 instance, volume attachment, and EIP are destroyed first
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "KuttPublicRouteTable"
  }

  depends_on = [aws_internet_gateway.igw]  # Ensure Internet Gateway exists before creating the route table
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public]  # Ensure route table exists before associating
}

resource "aws_instance" "kutt_instance" {
  ami                         = "ami-00e89f3f4910f40a1"
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = true

  tags = {
    Name = "KuttAppInstance"
  }

  user_data = file("${path.module}/setup.sh")

  depends_on = [aws_subnet.public, aws_security_group.allow_ssh_http]  # Ensure subnet and security group exist before creating the instance
}

resource "aws_ebs_volume" "kutt_storage" {
  availability_zone = aws_instance.kutt_instance.availability_zone
  size              = var.volume_size

  tags = {
    Name = "KuttStorage"
  }

  depends_on = [aws_instance.kutt_instance]  # Ensure instance exists before creating the volume
}

resource "aws_volume_attachment" "attach_ebs" {
  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.kutt_storage.id
  instance_id = aws_instance.kutt_instance.id

  depends_on = [aws_ebs_volume.kutt_storage, aws_instance.kutt_instance]  # Ensure both volume and instance exist before attaching
}

resource "aws_eip" "kutt_eip" {
  instance = aws_instance.kutt_instance.id

  tags = {
    Name = "KuttEIP"
  }

  depends_on = [aws_instance.kutt_instance]  # Ensure instance exists before creating the EIP
}
