// VPC Objects

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main_vpc"
    owner = "terraform"
  }
}

// If length(vpc_public_subnet_cidrs) > length(vpc_azs), this will fail
resource aws_subnet "public_subnets" {
  count = length(var.vpc_public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_public_subnet_cidrs[count.index]
  availability_zone = var.vpc_azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_${count.index + 1}"
    owner = "terraform"
  }
}

resource "aws_subnet" "private_subnets" {
  count      = length(var.vpc_private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.vpc_private_subnet_cidrs, count.index)
  tags = {
    Name = "public_subnet_${count.index + 1}"
    owner = "terraform"
  }
 }

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Project VPC IG"
    owner = "terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public_route_table"
    owner = "terraform"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

// Networking

resource "aws_eip_association" "loadbalancer" {
  instance_id = aws_instance.loadbalancer.id
  allocation_id = data.aws_eip.loadbalancer_ip[count.index].id
  count = var.loadbalancer_ip != null ? 1 : 0
}

resource "aws_security_group" "loadbalancer" {
  description = "Allow all outbound traffic"
  name   = "loadbalancer"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "loadbalancer_sg"
    owner = "terraform"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.loadbalancer_public_tcp_ports
    content {
      description = "Allow TCP port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Restricted ports by IP
  dynamic "ingress" {
    for_each = { for port in var.loadbalancer_restricted_ports_tcp : port => port }
    content {
      description = "Allow TCP port ${ingress.value} from allowed IPs"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = local.allowed_ips
    }
  }


}

resource "aws_key_pair" "aws_key" {
  key_name   = var.keypair_name
  public_key = var.keypair_key
  tags = {
    Name = "aws_key"
    owner = "terraform"
  }
}

resource "aws_instance" "loadbalancer" {
  associate_public_ip_address = true
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = aws_subnet.public_subnets[0].id
  instance_type          = var.loadbalancer_instance_type
  key_name               = aws_key_pair.aws_key.key_name
  vpc_security_group_ids = [aws_security_group.loadbalancer.id]
  source_dest_check      = false
  root_block_device {
    volume_size = var.loadbalancer_instance_disk_size
  }
  lifecycle {
    ignore_changes = [ami]
  }
  tags = {
    role = "loadbalancer"
    Name = "loadbalancer"
    owner = "terraform"
  }
}