provider "aws" {
  region = var.df_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block_a
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = var.public_ip
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block_b
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = var.public_ip
}

resource "aws_security_group" "dp5_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = var.ssh_access.from_port
    to_port     = var.ssh_access.to_port
    protocol    = var.ssh_access.protocol
    cidr_blocks = var.ssh_access.cidr_blocks
  }

  ingress {
    from_port   = var.http_access.from_port
    to_port     = var.http_access.to_port
    protocol    = var.http_access.protocol
    cidr_blocks = var.http_access.cidr_blocks
  }

  ingress {
    from_port   = var.jenkins_access.from_port
    to_port     = var.jenkins_access.to_port
    protocol    = var.jenkins_access.protocol
    cidr_blocks = var.jenkins_access.cidr_blocks
  }

  egress {
    from_port   = var.anywhere_outgoing.from_port
    to_port     = var.anywhere_outgoing.to_port
    protocol    = var.anywhere_outgoing.protocol
    cidr_blocks = var.anywhere_outgoing.cidr_blocks
  }
}

resource "aws_instance" "ec2_instance_1" {
  ami                             = var.ec2_ami_id
  instance_type                   = var.ec2_instance_type
  subnet_id                       = aws_subnet.subnet_1.id
  security_groups                 = [aws_security_group.dp5_1_sg.id]
  tags                            = var.ec2_instance_tag_1
  user_data                       = base64encode(file(var.ud_jenkins))
  associate_public_ip_address     = var.public_ip
  key_name                        = var.key_name
  iam_instance_profile            = var.machine_role
}

resource "aws_instance" "ec2_instance_2" {
  ami                             = var.ec2_ami_id
  instance_type                   = var.ec2_instance_type
  subnet_id                       = aws_subnet.subnet_2.id
  security_groups                 = [aws_security_group.dp5_1_sg.id]
  tags                            = var.ec2_instance_tag_2
  user_data                       = base64encode(file(var.ud_py_java))
  associate_public_ip_address     = var.public_ip
  key_name                        = var.key_name
  iam_instance_profile            = var.machine_role
}

resource "aws_instance" "ec2_instance_3" {
  ami                             = var.ec2_ami_id
  instance_type                   = var.ec2_instance_type
  subnet_id                       = aws_subnet.subnet_1.id
  security_groups                 = [aws_security_group.dp5_sg.id]
  tags                            = var.ec2_instance_tag_3
  user_data                       = base64encode(file(var.ud_py_java))
  associate_public_ip_address     = var.public_ip
  key_name                        = var.key_name
  iam_instance_profile            = var.machine_role
}

resource "aws_internet_gateway" "dp5_1_igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.df_cidr_block_anywhere
    gateway_id = aws_internet_gateway.dp5_igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.main.id
}
