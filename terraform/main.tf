// Networking

resource "aws_eip" "wireguard" {
  instance = aws_instance.wireguard.id

  tags = {
    Name : "wireguard"
  }
}

resource "aws_security_group" "wireguard" {
  name   = "wireguard"
  vpc_id = module.vpc_main.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

//  ingress {
//    from_port   = 53
//    to_port     = 53
//    protocol    = "udp"
//    cidr_blocks = [var.gateway_network]
//  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.gateway_network]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.gateway_network]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc_main" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "wireguard"
  cidr                 = var.vpc_cidr
  public_subnets       = var.vpc_public_subnets
  azs                  = var.vpc_azs
  enable_dns_hostnames = true
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

resource "aws_instance" "tester" {
  associate_public_ip_address = true
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




