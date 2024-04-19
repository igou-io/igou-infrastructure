// Networking

resource "aws_eip_association" "wireguard" {
  instance_id = aws_instance.wireguard.id
  allocation_id = data.aws_eip.wireguard_ip[count.index].id
  count = var.wireguard_ip != null ? 1 : 0
}

resource "aws_eip_association" "loadbalancer" {
  instance_id = aws_instance.loadbalancer.id
  allocation_id = data.aws_eip.loadbalancer_ip[count.index].id
  count = var.loadbalancer_ip != null ? 1 : 0
}

resource "aws_security_group" "loadbalancer" {
  name   = "loadbalancer"
  vpc_id = module.vpc_main.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wireguard" {
  name   = "wireguard"
  vpc_id = module.vpc_main.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_all_443_inbound_loadbalanacer" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.loadbalancer.id
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_30443_from_loadbalancer" {
    type = "ingress"
    from_port = 30443
    to_port = 30443
    protocol = "tcp"
    security_group_id = aws_security_group.wireguard.id
    source_security_group_id = aws_security_group.loadbalancer.id
}

resource "aws_security_group_rule" "allow_6443_from_loadbalancer" {
    type = "ingress"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    security_group_id = aws_security_group.wireguard.id
    source_security_group_id = aws_security_group.loadbalancer.id
}

resource "aws_security_group_rule" "allow_22_from_wireguard" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = aws_security_group.loadbalancer.id
    source_security_group_id = aws_security_group.wireguard.id
}

resource "aws_security_group_rule" "allow_6443_from_sourceip" {
    type = "ingress"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    security_group_id = aws_security_group.loadbalancer.id
}

resource "aws_security_group_rule" "allow_51820_from_sourceip" {
    type = "ingress"
    from_port = 51820
    to_port = 51820
    protocol = "udp"
    security_group_id = aws_security_group.wireguard.id
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
}

resource "aws_security_group_rule" "allow_22_from_sourceip" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = aws_security_group.wireguard.id
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
}

resource "aws_route" "gateway_route" {
  route_table_id         = module.vpc_main.public_route_table_ids[0]
  destination_cidr_block = "10.10.1.0/24"
  network_interface_id   = aws_instance.wireguard.primary_network_interface_id
}

// Instances

resource "aws_key_pair" "wireguard" {
  key_name   = var.keypair_name
  public_key = var.keypair_key
}

resource "aws_instance" "loadbalancer" {
  associate_public_ip_address = true
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = module.vpc_main.public_subnets[0]
  instance_type          = var.loadbalancer_instance_type
  key_name               = aws_key_pair.wireguard.key_name
  vpc_security_group_ids = concat(data.aws_security_group.k8s_security_groups.*.id, [aws_security_group.loadbalancer.id])
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
  }
}

resource "aws_instance" "wireguard" {
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = module.vpc_main.public_subnets[0]
  instance_type          = var.gateway_instance_type
  key_name               = aws_key_pair.wireguard.key_name
  vpc_security_group_ids = concat(data.aws_security_group.wireguard_security_groups.*.id, [aws_security_group.wireguard.id])
  source_dest_check      = false
  root_block_device {
    volume_size = var.gateway_instance_disk_size
  }
  lifecycle {
    ignore_changes = [ami]
  }
  tags = {
    role = "wireguard_endpoint"
    Name = "wireguard_endpoint"
  }
}
