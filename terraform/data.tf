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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] // canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
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
