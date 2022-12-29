// Networking

module "vpc_main" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "wireguard"
  cidr                 = var.vpc_cidr
  public_subnets       = var.vpc_public_subnets
  azs                  = var.vpc_azs
  enable_dns_hostnames = true
}

resource "aws_eip" "wireguard" {
  instance = aws_instance.wireguard.id
  tags = {
    Name : "wireguard"
  }
}


resource "aws_security_group" "kubernetes_ingress" {
  name   = "kubernetes_ingress"
  vpc_id = module.vpc_main.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.wireguard.id]
  }
  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    security_groups = [aws_security_group.wireguard.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "loadbalancer" {
  name   = "loadbalancer"
  vpc_id = module.vpc_main.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.wireguard.id]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
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
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_443_from_loadbalancer" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.kubernetes_ingress.id
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

resource "aws_security_group_rule" "allow_6443_from_kubernetes_ingress" {
    type = "ingress"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    security_group_id = aws_security_group.wireguard.id
    source_security_group_id = aws_security_group.kubernetes_ingress.id
}

resource "aws_route" "gateway_route" {
  route_table_id         = module.vpc_main.public_route_table_ids[0]
  destination_cidr_block = "10.10.1.0/24"
  network_interface_id   = aws_instance.wireguard.primary_network_interface_id
}

// Instances

resource "aws_key_pair" "wireguard" {
  key_name   = "wireguard"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDumonWRoahxRVNYQT6dt76OkYyRThQ1e0Z/lAAMHcF4ffpZ138fZVWFHipT9f85EOqLkleqLWH6b3yj37+zOOCJ4lGoTSk0oFK92neiWLGV6ayTsvGojdV/cGrSefUP04FqleZirSiwv52FYEVA21vPNweaB70L3m4i7x7+VaHqVvtPh4qT0LnnWa2Yf6Oq6aQU0WUi7Sd388SVczcWVZlJ9L+iibjtir1sm0NUE4Z+sEwHYCOfO2m6YbN809z2GQz1q+DchM0cJhpwBmwH+MIv3wjahM4Khz+XNz4bjousak63BMnZwqROf4jkoQoMrvy3Q/4WZHvivkLTu/Bj51p7TtFPTN1XNHq4kt5qzLE63HsQyhOy9lGdZpLk8cigZe14aQ1NV5WbXm0YSgPIdXTNgpHtXxzUGHjioqEhoMx4q/YBbIHZAFrX8eYorE0nhSzE63HA4cJsjMS56zAs3gk6SaG2Vux04+NwhAOftbQpF8wzwbS0QzdPzw42XKHMVDmQEW/YtPw8XVC15mmHTu6QEYjzBBYU6Noi37PXWOrad2wkq5bInIdlH6VBRuOQ0tw+9VeUlnYUoS9fD8lxcsuGiN3iVaLH8R4kptirEnr0VUBblo3fe1M3YqNiuqXpcB4HJ7sEaKIcyqEetGFRYFmbnvj4iM9BJ5uDb3pgzzmYw== digou@redhat.com" //var.gateway_ssh_public_key
}

resource "aws_instance" "loadbalancer" {
  associate_public_ip_address = true
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = module.vpc_main.public_subnets[0]
  instance_type          = var.loadbalancer_instance_type
  key_name               = aws_key_pair.wireguard.key_name
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
  }
}

resource "aws_instance" "kubernetes_ingress" {
  ami                    = data.aws_ami.ubuntu.id
  count                  = var.kubernetes_ingress_instance_count
  subnet_id              = module.vpc_main.public_subnets[0]
  instance_type          = var.kubernetes_ingress_instance_type
  key_name               = aws_key_pair.wireguard.key_name
  vpc_security_group_ids = [aws_security_group.kubernetes_ingress.id]
  source_dest_check      = false
  root_block_device {
    volume_size = var.kubernetes_ingress_instance_disk_size
  }
  lifecycle {
    ignore_changes = [ami]
  }
  tags = {
    role = "cluster_ingress"
    Name = "cluster_ingress-${count.index}"
    "kubernetes.io/cluster/default" = "owned"
  }
}

resource "aws_instance" "wireguard" {
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = module.vpc_main.public_subnets[0]
  instance_type          = var.gateway_instance_type
  key_name               = aws_key_pair.wireguard.key_name
  vpc_security_group_ids = [aws_security_group.wireguard.id]
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
