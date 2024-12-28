data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

// If provided IPs are null, do nothing
data "aws_eip" "loadbalancer_ip" {
  public_ip = var.loadbalancer_ip
  count = var.loadbalancer_ip != null ? 1 : 0
}

data "aws_eip" "wireguard_ip" {
  public_ip = var.wireguard_ip
  count = var.wireguard_ip != null ? 1 : 0
}

data "aws_security_group" "wireguard_security_groups" {
  count = length(data.aws_security_groups.wireguard_security_groups.ids)

  id = data.aws_security_groups.wireguard_security_groups.ids[count.index]
}

data "aws_security_groups" "wireguard_security_groups" {
  filter {
    name   = "tag:wireguard"
    values = ["true"]
  }
}

data "aws_security_group" "k8s_security_groups" {
  count = length(data.aws_security_groups.k8s_security_groups.ids)

  id = data.aws_security_groups.k8s_security_groups.ids[count.index]
}

data "aws_security_groups" "k8s_security_groups" {
  filter {
    name   = "tag:k8scli"
    values = ["true"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] // canonical

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-minimal-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}
